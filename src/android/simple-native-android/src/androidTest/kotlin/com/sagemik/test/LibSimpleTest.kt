package com.sagemik.test

import android.content.Context
import androidx.sqlite.db.SupportSQLiteDatabase
import androidx.sqlite.db.SupportSQLiteOpenHelper
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.google.common.truth.Truth.assertThat
import io.requery.android.database.sqlite.RequerySQLiteOpenHelperFactory
import io.requery.android.database.sqlite.SQLiteCustomExtension
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class LibSimpleTest {
    private lateinit var context: Context

    @Before
    fun before() {
        context = ApplicationProvider.getApplicationContext()
    }

    @Test
    fun testSimpleQuery() {
        val dbHelper = context.createSQLiteOpenHelper()
        val db = dbHelper.readableDatabase

        val cursor = db.query("SELECT simple_highlight(t1, 0, '[', ']') FROM t1 WHERE text MATCH simple_query('z s');")
        cursor.moveToFirst()
        val result = cursor.getString(0)
        println(result)
        assertThat(result).isEqualTo("人工[智]能[正在]改变我们的[生]活方[式]")

        cursor.close()
        db.close()
    }
}

fun Context.createSQLiteOpenHelper(): SupportSQLiteOpenHelper {
    val extensionConfigs = mutableListOf(
        RequerySQLiteOpenHelperFactory.ConfigurationOptions {
            it.apply {
                customExtensions += SQLiteCustomExtension("libsimple.so", "sqlite3_simple_init") // 加载 Simple 扩展
            }
        }
    )
    return RequerySQLiteOpenHelperFactory(extensionConfigs).create(
        SupportSQLiteOpenHelper.Configuration( // 根据需要调整数据库配置
            this, ":memery:", object : SupportSQLiteOpenHelper.Callback(1) {
                override fun onCreate(db: SupportSQLiteDatabase) {
                    db.apply {
                        execSQL("CREATE VIRTUAL TABLE t1 USING fts5(text, tokenize = 'simple')")
                        execSQL("INSERT INTO t1 (text) VALUES (?);", arrayOf("人工智能正在改变我们的生活方式"))
                    }
                }

                override fun onUpgrade(
                    db: SupportSQLiteDatabase,
                    oldVersion: Int,
                    newVersion: Int
                ) {}
            }
        )
    )
}