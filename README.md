# simple-native-kmp

```
#
# A fatal error has been detected by the Java Runtime Environment:
#
#  EXCEPTION_ACCESS_VIOLATION (0xc0000005) at pc=0x00007ffad0f83080, pid=6464, tid=3472
#
# JRE version: OpenJDK Runtime Environment (21.0.10) (build 21.0.10+-14961533-b1163.108)
# Java VM: OpenJDK 64-Bit Server VM (21.0.10+-14961533-b1163.108, mixed mode, tiered, compressed oops, compressed class ptrs, g1 gc, windows-amd64)
# Problematic frame:
# C  [msvcp140.dll+0x13080]
#
# No core dump will be written. Minidumps are not enabled by default on client versions of Windows
#
Unexpected exception thrown.
org.gradle.internal.remote.internal.MessageIOException: Could not write '/127.0.0.1:13092'.
at org.gradle.internal.remote.internal.inet.SocketConnection.flush(SocketConnection.java:142)
at org.gradle.internal.remote.internal.hub.MessageHub$ConnectionDispatch.run(MessageHub.java:333)
at org.gradle.internal.concurrent.ExecutorPolicy$CatchAndRecordFailures.onExecute(ExecutorPolicy.java:64)
at org.gradle.internal.concurrent.AbstractManagedExecutor$1.run(AbstractManagedExecutor.java:48)
at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(Unknown Source)
at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(Unknown Source)
at java.base/java.lang.Thread.run(Unknown Source)
Caused by: java.io.IOException: Connection reset by peer
at java.base/sun.nio.ch.SocketDispatcher.write0(Native Method)
at java.base/sun.nio.ch.SocketDispatcher.write(Unknown Source)
at java.base/sun.nio.ch.IOUtil.writeFromNativeBuffer(Unknown Source)
at java.base/sun.nio.ch.IOUtil.write(Unknown Source)
at java.base/sun.nio.ch.IOUtil.write(Unknown Source)
at java.base/sun.nio.ch.SocketChannelImpl.write(Unknown Source)
at org.gradle.internal.remote.internal.inet.SocketConnection$SocketOutputStream.writeWithNonBlockingRetry(SocketConnection.java:282)
at org.gradle.internal.remote.internal.inet.SocketConnection$SocketOutputStream.writeBufferToChannel(SocketConnection.java:269)
at org.gradle.internal.remote.internal.inet.SocketConnection$SocketOutputStream.flush(SocketConnection.java:263)
at org.gradle.internal.remote.internal.inet.SocketConnection.flush(SocketConnection.java:140)
... 6 more
```
https://youtrack.jetbrains.com/issue/JBR-9941
https://github.com/JetBrains/JetBrainsRuntime/releases/tag/jbr-release-21.0.10b1163.110
