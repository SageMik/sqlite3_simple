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
        await db.execute("INSERT INTO t1 (text) VALUES (?);", ["示 (qí)，通「祇」，地神。《周礼·春官·大宗伯》：「大宗伯之职，掌建邦之天神人鬼地示之礼。」。汉·郑玄·注：「示，音祇，本或作祇。」"])

        const resultSet = await db.querySql("SELECT simple_highlight(t1, 0, '[', ']') as c0 FROM t1 WHERE text MATCH simple_query('qi');")
        resultSet.goToFirstRow()
        result = resultSet.getRow()["c0"]?.toString()

        resultSet.close()
        db.close().catch()
      } catch (error) {
        result = error
      }
      expect(result).assertEqual("示 (qí)，通「[祇]」，地神。《周礼·春官·大宗伯》：「大宗伯之职，掌建邦之天神人鬼地示之礼。」。汉·郑玄·注：「示，音[祇]，本或作[祇]。」")
    })
  })
}