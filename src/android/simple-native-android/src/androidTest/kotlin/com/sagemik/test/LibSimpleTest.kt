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

        val cursor = db.query(
            "SELECT simple_highlight(t1, 0, '[', ']') FROM t1 WHERE text MATCH simple_query('qi');"
        )
        cursor.moveToFirst()
        val result = cursor.getString(0)
        println(result)
        assertThat(result).isEqualTo("示 (qí)，通「[祇]」，地神。《周礼·春官·大宗伯》：「大宗伯之职，掌建邦之天神人鬼地示之礼。」。汉·郑玄·注：「示，音[祇]，本或作[祇]。」")

        cursor.close()
        db.close()
    }
}

fun Context.createSQLiteOpenHelper(): SupportSQLiteOpenHelper {
    val extensionConfigs = mutableListOf(
        RequerySQLiteOpenHelperFactory.ConfigurationOptions {
            it.apply {
                customExtensions += SQLiteCustomExtension(
                    "libsimple.so",
                    "sqlite3_simple_init"
                ) // 加载 Simple 扩展
            }
        }
    )
    return RequerySQLiteOpenHelperFactory(extensionConfigs).create(
        SupportSQLiteOpenHelper.Configuration( // 根据需要调整数据库配置
            this, ":memery:", object : SupportSQLiteOpenHelper.Callback(1) {
                override fun onCreate(db: SupportSQLiteDatabase) {
                    db.apply {
                        execSQL("CREATE VIRTUAL TABLE t1 USING fts5(text, tokenize = 'simple')")
                        execSQL(
                            sql = "INSERT INTO t1 (text) VALUES (?);",
                            bindArgs = arrayOf("示 (qí)，通「祇」，地神。《周礼·春官·大宗伯》：「大宗伯之职，掌建邦之天神人鬼地示之礼。」。汉·郑玄·注：「示，音祇，本或作祇。」")
                        )
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
}