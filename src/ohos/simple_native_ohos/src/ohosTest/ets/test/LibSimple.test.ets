import { describe, expect, it } from '@ohos/hypium'
import { abilityDelegatorRegistry } from '@kit.TestKit'
import { relationalStore } from '@kit.ArkData'
import { resolveLibSimplePath } from '../../../main/ets/lib'

const delegator = abilityDelegatorRegistry.getAbilityDelegator()

export default function LibSimpleTest() {
  describe('LibSimpleTest', () => {
    it('testSimpleQuery', 0, async () => {
      let result: string | undefined
      try {
        const context = (await delegator.getCurrentTopAbility()).context

        // Simple 原生库路径
        const libSimple = resolveLibSimplePath(context)
        const storeConfig: relationalStore.StoreConfig = {
          name: 'test.db',
          securityLevel: relationalStore.SecurityLevel.S1,
          pluginLibs: [libSimple], // 加载 Simple 扩展
        }
        const db = await relationalStore.getRdbStore(context, storeConfig)
        await db.executeSql("CREATE VIRTUAL TABLE t1 USING fts5(text, tokenize = 'simple')")
        await db.execute("INSERT INTO t1 (text) VALUES (?);", ["人工智能正在改变我们的生活方式"])

        const resultSet = await db.querySql("SELECT simple_highlight(t1, 0, '[', ']') as c0 FROM t1 WHERE text MATCH simple_query('z s');")
        resultSet.goToFirstRow()
        result = resultSet.getRow()["c0"]?.toString()

        resultSet.close()
        db.close().catch()
      } catch (error) {
        result = error
      }
      expect(result).assertEqual("人工[智]能[正在]改变我们的[生]活方[式]")
    })
  })
}