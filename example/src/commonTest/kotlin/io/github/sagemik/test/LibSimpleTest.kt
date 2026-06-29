package io.github.sagemik.test

import androidx.sqlite.SQLiteConnection
import androidx.sqlite.driver.bundled.BundledSQLiteDriver
import androidx.sqlite.execSQL
import com.goncalossilva.resources.Resource
import io.github.loshine.multiplatform.pathprovider.getApplicationDocumentsDirectory
import io.github.loshine.multiplatform.pathprovider.setApplicationId
import io.github.sagemik.simplenative.LibSimple
import okio.FileSystem
import okio.Path
import okio.Path.Companion.toPath
import okio.SYSTEM
import kotlin.test.Test
import kotlin.test.assertEquals

val resourcesDir get() = getApplicationDocumentsDirectory().toPath() / "simple-native-kmp"

class LibSimpleTest {
    enum class Tokenizer { Simple, Jieba }

    /**
     * 首次创建数据库，执行 [block] 中的命令，用于首次创表
     */
    private fun SQLiteConnection.onCreate(block: SQLiteConnection.() -> Unit) = apply {
        val userVersion = prepare("PRAGMA user_version").use { stmt ->
            check(stmt.step())
            stmt.getInt(0)
        }
        if (userVersion == 0) {
            block(this)
            execSQL("PRAGMA user_version = 1")
        }
    }

    val fileSystem = FileSystem.SYSTEM

    /** Simple 原生库路径，如 Android 是 [LibSimple.name] 即 `libsimple.so`，JVM 则需要手动将原生库写到本地以供使用 */
    val libSimplePath by lazy { fileSystem.initLibSimple() }

    /** 结巴分词字典在资源中的目录 */
    val jiebaDictResourcesDir = "cpp_jieba_dict"

    /** 结巴分词字典写到本地的目录 */
    val jiebaDictLocalDir: Path by lazy { resourcesDir / jiebaDictResourcesDir }

    /** 数据库连接 */
    val connection: SQLiteConnection = run {

        /** 指定 Simple 扩展；打开数据库；首次创表 */
        println("Simple 原生库路径：$libSimplePath")
        val driver = BundledSQLiteDriver().apply {
            addExtension(libSimplePath, LibSimple.entrypoint) // 指定 Simple 原生库路径和入口
        }
        val connection = driver.open(":memory:")
            .onCreate {
                execSQL("CREATE VIRTUAL TABLE t1 USING fts5(text, tokenize = 'simple')")
                prepare("INSERT INTO t1 (text) VALUES (?)").use {
                    for (text in arrayOf(
                        "示 (qí)，通「祇」，地神。《周礼·春官·大宗伯》：「大宗伯之职，掌建邦之天神人鬼地示之礼。」。汉·郑玄·注：「示，音祇，本或作祇。」",
                        "LINQ 是将查询功能直接集成到 C# 语言中的一组技术，它让开发者可以使用编程语言本身的语法对不同数据源进行查询，而不是 SQL 字符串。"
                    )) {
                        it.reset()
                        it.bindText(1, text)
                        it.step()
                    }
                }
            }

        /** 将结巴分词字典文件保存到本地路径，调用 `SELECT jieba_dict()` 指定路径以供 Simple 扩展读取 */
        println("结巴分词字典路径：$jiebaDictLocalDir")
        fileSystem.apply {
            createDirectories(jiebaDictLocalDir)
            for (fileName in arrayOf("jieba.dict.utf8", "hmm_model.utf8", "idf.utf8", "stop_words.utf8", "user.dict.utf8")) {
                val asset = Resource("$jiebaDictResourcesDir/$fileName")
                write(jiebaDictLocalDir / fileName) {
                    write(asset.readBytes())
                }
            }
        }
        connection.execSQL("SELECT jieba_dict('$jiebaDictLocalDir')")

        return@run connection
    }

    @Test
    fun testQuery() {
        println()
        search(
            tokenizer = Tokenizer.Simple,
            query = "qi",
            expected = "示 (qí)，通「[祇]」，地神。《周礼·春官·大宗伯》：「大宗伯之职，掌建邦之天神人鬼地示之礼。」。汉·郑玄·注：「示，音[祇]，本或作[祇]。」"
        )
        search(
            tokenizer = Tokenizer.Jieba,
            query = "C#",
            expected = "LINQ 是将查询功能直接集成到 [C#] 语言中的一组技术，它让开发者可以使用编程语言本身的语法对不同数据源进行查询，而不是 SQL 字符串。"
        )
        println()

        connection.close()
        arrayOf(libSimplePath.toPath(), jiebaDictLocalDir).filter {
            val exits = fileSystem.exists(it)
            fileSystem.deleteRecursively(it)
            exits
        }.run {
            println("已清理：${joinToString()}")
        }
    }

    private fun search(tokenizer: Tokenizer, query: String, expected: String) {
        connection.prepare(
            "SELECT simple_highlight(t1, 0, '[', ']') FROM t1 WHERE text MATCH ${tokenizer.name.lowercase()}_query('$query');"
        ).use {
            check(it.step())
            val result = it.getText(0)
            println("查询 \"${query}\" ：$result")
            assertEquals(expected, result)
        }
    }
}

expect fun FileSystem.initLibSimple(): String