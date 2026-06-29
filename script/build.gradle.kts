import java.net.URI
import java.security.cert.X509Certificate
import javax.net.ssl.HostnameVerifier
import javax.net.ssl.HttpsURLConnection
import javax.net.ssl.SSLContext
import javax.net.ssl.X509TrustManager
import kotlin.apply

interface Injected {
    @get:Inject
    val fs: FileSystemOperations

    @get:Inject
    val archives: ArchiveOperations
}

tasks.register("syncJvmNativeLibs") {
    group = "simple-native"
    description = "版本升级后，下载 `libsimple.zip` 进行同步"

    /** 修复 Gradle 配置缓存问题：https://docs.gradle.org/9.5.1/userguide/configuration_cache_requirements.html#config_cache:requirements:disallowed_types */
    val injected = project.objects.newInstance<Injected>()
    val rootProjectDir = rootProject.projectDir

    val version = project(":simple-native-kmp").version.toString()
    val cachedZipFile = layout.buildDirectory.file("libsimple.zip").get().asFile
    val zipPath = providers.gradleProperty("zip")
    val mappings = mapOf(
        "windows/simple.dll" to ":platforms:jvm-windows",
        "macos/libsimple.dylib" to ":platforms:jvm-macos",
//        "linux/libsimple.so" to ":platforms:jvm-linux",
    ).mapValues { (zipEntry, projectPath) ->
        project(projectPath).run {
            projectDir.relativeTo(rootProjectDir).invariantSeparatorsPath +
                    "/src/main/resources/io/sagemik/simplenative/$zipEntry"
        }
    }
    println("JVM 平台路径：$mappings")

    /** 跳过 SSL 验证 */
    fun URI.openTrustAllStream() =
        (toURL().openConnection() as HttpsURLConnection).apply {
            sslSocketFactory = SSLContext.getInstance("TLS").apply {
                init(null, arrayOf(object : X509TrustManager {
                    override fun checkClientTrusted(
                        chain: Array<out X509Certificate>?,
                        authType: String?
                    ) = Unit

                    override fun checkServerTrusted(
                        chain: Array<out X509Certificate>?,
                        authType: String?
                    ) = Unit

                    override fun getAcceptedIssuers() = emptyArray<X509Certificate>()
                }), null)
            }.socketFactory
            hostnameVerifier = HostnameVerifier { _, _ -> true }
        }.inputStream

    doLast {
        injected.apply {
            if (zipPath.isPresent) {
                fs.copy {
                    from(zipPath.get())
                    into(cachedZipFile.parentFile)
                }
            } else if (!cachedZipFile.exists()) {
                val url =
                    "https://github.com/SageMik/sqlite3_simple/releases/download/Nv$version/libsimple.zip"
                logger.lifecycle("Downloading $url to $cachedZipFile")
                cachedZipFile.parentFile.mkdirs()
                URI(url).openTrustAllStream().use { input ->
                    cachedZipFile.outputStream().use(input::copyTo)
                }
            }

            fs.copy {
                from(archives.zipTree(cachedZipFile)) {
                    include(mappings.keys)
                    eachFile {
                        val zipEntry = relativePath.pathString
                        val dest = mappings.getValue(zipEntry)
                        relativePath = RelativePath(true, *dest.split('/').toTypedArray())
                    }

                    /** 避免复制空目录到根目录：https://docs.gradle.org/current/userguide/working_with_files.html#using_project_zip_tree_and_tar_tree */
                    includeEmptyDirs = false
                }
                into(rootProjectDir)
            }
        }
    }
}
