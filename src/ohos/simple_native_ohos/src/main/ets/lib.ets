import { deviceInfo } from "@kit.BasicServicesKit"

/**
 * @param context `Application` 或 `Ability` 的上下文。
 * @returns 根据当前设备 ABI 获取的 Simple 分词器原生库路径。打开数据库时，将其作为 `relationalStore.StoreConfig.pluginLibs` 配置项传入即可。
 */
export function resolveLibSimplePath(context: Context): string {
  let abi = deviceInfo.abiList.startsWith("x86") ? "x86_64" : "arm64" // 目前鸿蒙只支持这两种架构
  return `${context.bundleCodeDir}/libs/${abi}/libsimple.so`
}