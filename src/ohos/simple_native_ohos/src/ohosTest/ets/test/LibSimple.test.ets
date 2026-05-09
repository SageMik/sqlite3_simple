import { afterAll, beforeAll, describe, expect, it } from '@ohos/hypium'
import { abilityDelegatorRegistry } from '@kit.TestKit'
import { relationalStore } from '@kit.ArkData'
import { resolveLibSimplePath } from '../../../main/ets/lib'
import { fileIo } from '@kit.CoreFileKit'

export default function LibSimpleTest() {
  describe('LibSimpleTest', () => {
    let db: relationalStore.RdbStore;

    beforeAll(async () => {
      try {
        const context = (await abilityDelegatorRegistry.getAbilityDelegator().getCurrentTopAbility()).context

        /** 加载 Simple 扩展 */
        const libSimple = resolveLibSimplePath(context)
        const storeConfig: relationalStore.StoreConfig = {
          name: 'test.db',
          securityLevel: relationalStore.SecurityLevel.S1,
          pluginLibs: [libSimple],
        }

        /** 打开数据库 */
        db = await relationalStore.getRdbStore(context, storeConfig)
        await db.executeSql("CREATE VIRTUAL TABLE t1 USING fts5(text, tokenize = 'simple')")
        await db.batchInsert("t1", [
          {
            "text": "示 (qí)，通「祇」，地神。《周礼·春官·大宗伯》：「大宗伯之职，掌建邦之天神人鬼地示之礼。」。汉·郑玄·注：「示，音祇，本或作祇。」"
          },
          {
            "text": "LINQ 是将查询功能直接集成到 C# 语言中的一组技术，它让开发者可以使用编程语言本身的语法对不同数据源进行查询，而不是 SQL 字符串。"
          }
        ])

        /** 将结巴分词字典文件保存到可以路径访问的目录，调用 `SELECT jieba_dict()` 指定以便 Simple 扩展读取 */
        const assetDir = "cpp_jieba_dict"
        const dictDir = `${context.filesDir}/${assetDir}`
        if (!(await fileIo.access(dictDir, fileIo.AccessModeType.EXIST))) {
          await fileIo.mkdir(dictDir, true)
          for (const fileName of ["jieba.dict.utf8", "hmm_model.utf8", "idf.utf8", "stop_words.utf8",
            "user.dict.utf8"]) {
            const rawData = await context.resourceManager.getRawFileContent(`${assetDir}/${fileName}`)
            const file =
              await fileIo.open(`${dictDir}/${fileName}`, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
            await fileIo.write(file.fd, rawData.buffer)
            await fileIo.close(file)
          }
        }
        await db.querySql(`SELECT jieba_dict('${dictDir}')`)

      } catch (e) {
        throw wrapError(e)
      }
    })

    it('testSimpleQuery', 0, async () => {
      try {
        checkFirstAndClose(
          await db.querySql("SELECT simple_highlight(t1, 0, '[', ']') FROM t1 WHERE text MATCH simple_query('qi');"),
          "示 (qí)，通「[祇]」，地神。《周礼·春官·大宗伯》：「大宗伯之职，掌建邦之天神人鬼地示之礼。」。汉·郑玄·注：「示，音[祇]，本或作[祇]。」"
        )
      } catch (error) {
        throw wrapError(error)
      }
    })

    it('testJiebaQuery', 0, async () => {
      try {
        checkFirstAndClose(
          await db.querySql("SELECT simple_highlight(t1, 0, '[', ']') FROM t1 WHERE text MATCH jieba_query('C#');"),
          "LINQ 是将查询功能直接集成到 [C#] 语言中的一组技术，它让开发者可以使用编程语言本身的语法对不同数据源进行查询，而不是 SQL 字符串。"
        )
      } catch (error) {
        throw wrapError(error)
      }
    })

    afterAll(async () => {
      try {
        await db.close()
      } catch (e) {
        throw wrapError(e)
      }
    })
  })
}

function checkFirstAndClose(resultSet: relationalStore.ResultSet, expected: String): string {
  let result: string
  try {
    resultSet.goToFirstRow()
    result = Object.values(resultSet.getRow())[0]!.toString()
    resultSet.close()
    expect(result).assertEqual(expected)
  } catch (e) {
    throw wrapError(e)
  }
  return result
}

function wrapError<T>(error: T): Error {
  return error instanceof Error ? error : new Error(String(error))
}