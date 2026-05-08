package com.sagemik.test

import android.content.Context
import android.database.Cursor
import androidx.sqlite.db.SupportSQLiteDatabase
import androidx.sqlite.db.SupportSQLiteOpenHelper
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.google.common.truth.Truth.assertThat
import io.requery.android.database.sqlite.RequerySQLiteOpenHelperFactory
import io.requery.android.database.sqlite.SQLiteCustomExtension
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import java.io.File
import java.io.FileOutputStream

@RunWith(AndroidJUnit4::class)
class LibSimpleTest {
    lateinit var dbHelper: SupportSQLiteOpenHelper
    
    @Before
    fun before() {
        val context: Context = ApplicationProvider.getApplicationContext()

        /** 加载 Simple 扩展 */
        val extensionConfigs = listOf(
            RequerySQLiteOpenHelperFactory.ConfigurationOptions {
                it.apply {
                    customExtensions += SQLiteCustomExtension(
                        "libsimple.so",
                        "sqlite3_simple_init"
                    ) // 加载 Simple 扩展
                }
            }
        )

        /** 打开数据库 */
        dbHelper = RequerySQLiteOpenHelperFactory(extensionConfigs).create(
            SupportSQLiteOpenHelper.Configuration( // 根据需要调整数据库配置
                context, ":memory:", object : SupportSQLiteOpenHelper.Callback(1) {
                    override fun onCreate(db: SupportSQLiteDatabase) {
                        db.apply {
                            execSQL("CREATE VIRTUAL TABLE t1 USING fts5(text, tokenize = 'simple')")
                            val insertStatement = compileStatement("INSERT INTO t1 (text) VALUES (?)")
                            for(text in arrayOf(
                                "示 (qí)，通「祇」，地神。《周礼·春官·大宗伯》：「大宗伯之职，掌建邦之天神人鬼地示之礼。」。汉·郑玄·注：「示，音祇，本或作祇。」",
                                "LINQ 是将查询功能直接集成到 C# 语言中的一组技术，它让开发者可以使用编程语言本身的语法对不同数据源进行查询，而不是 SQL 字符串。"
                            )) {
                                insertStatement.apply {
                                    clearBindings()
                                    bindString(1, text)
                                    executeInsert()
                                }
                            }
                        }
                    }

                    override fun onUpgrade(
                        db: SupportSQLiteDatabase,
                        oldVersion: Int,
                        newVersion: Int
                    ) {
                    }
                }
            )
        )

        /** 将结巴分词字典文件保存到可以路径访问的目录，调用 `SELECT jieba_dict() 指定以便 Simple 扩展读取` */
        val assetDir = "cpp_jieba_dict"
        val dictDir = File(context.filesDir, assetDir)
        dictDir.mkdirs()
        context.assets.list(assetDir)!!.forEach { fileName ->
            context.assets.open("$assetDir/$fileName").use { inputStream ->
                FileOutputStream(File(dictDir, fileName)).use { outputStream ->
                    inputStream.copyTo(outputStream)
                }
            }
        }
        dbHelper.readableDatabase.query("SELECT jieba_dict(?)", arrayOf(dictDir.path))
            .moveToFirst() /** 注意要对游标进行操作，否则这条语句不会执行 */
    }

    @Test
    fun testSimpleQuery() {
        dbHelper.readableDatabase.query(
            "SELECT simple_highlight(t1, 0, '[', ']') FROM t1 WHERE text MATCH simple_query('qi');"
        ).checkFirstAndClose(
            "示 (qí)，通「[祇]」，地神。《周礼·春官·大宗伯》：「大宗伯之职，掌建邦之天神人鬼地示之礼。」。汉·郑玄·注：「示，音[祇]，本或作[祇]。」"
        )
    }

    @Test
    fun testJiebaQuery() {
        dbHelper.readableDatabase.query(
            "SELECT simple_highlight(t1, 0, '[', ']') FROM t1 WHERE text MATCH jieba_query('C#');"
        ).checkFirstAndClose(
            "LINQ 是将查询功能直接集成到 [C#] 语言中的一组技术，它让开发者可以使用编程语言本身的语法对不同数据源进行查询，而不是 SQL 字符串。"
        )
    }

    private fun Cursor.checkFirstAndClose(expected: String) {
        moveToFirst()
        val result = getString(0)
        println(result)
        assertThat(result).isEqualTo(expected)
        close()
    }

    @After
    fun after() {
        dbHelper.close()
    }
}