{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();

    const splash = document.getElementById('app-splash');
    if (!splash) return;

    splash.classList.add('app-splash--hidden');
    window.setTimeout(() => {
      // A hot restart can replace the document body before this callback runs.
      // Only detach the splash when it still belongs to the current document.
      if (splash.isConnected && splash.parentNode) {
        splash.parentNode.removeChild(splash);
      }
    }, 180);
  },
});
