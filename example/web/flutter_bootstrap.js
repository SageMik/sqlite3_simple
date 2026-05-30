{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
    config: {
        'canvasKitBaseUrl': new URL('./canvaskit/', document.baseURI).href,
    },
    serviceWorkerSettings: {
        serviceWorkerVersion: {{flutter_service_worker_version}},
    },
    onEntrypointLoaded: async function (engineInitializer) {
        const appRunner = await engineInitializer.initializeEngine({
            'fontFallbackBaseUrl': 'https://fonts.gstatic.cn/s/',
        });
        await appRunner.runApp();
        const loader = document.getElementById('loading-indicator');
        if (loader) {
            loader.style.opacity = '0';
            setTimeout(() => {
                loader.remove();
            }, 500);
        }
    },
});
