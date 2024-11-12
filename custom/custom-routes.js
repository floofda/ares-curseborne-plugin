export default function setupCustomRoutes(router) {
  // Define your own custom routes here, just as you would in router.js but using 'router' instead of 'this'.
  // For example:
  // router.route('yourroute');
  router.route('cod-census');
  router.route('cod-settings');
  router.route('cod-play'),
    router.route('scene-focus', { path: '/scene-focus/:id' });
}
