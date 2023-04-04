import { createRouter, createWebHistory, type RouteRecord, type RouteRecordNormalized } from 'vue-router'
import HomeView from '../views/DashboardView.vue'

const routes = [
  {
    path: '',
    name: 'home',
    component: HomeView
  },
  {
    path: '/about',
    name: 'about',
    // route level code-splitting
    // this generates a separate chunk (About.[hash].js) for this route
    // which is lazy-loaded when the route is visited.
    component: () => import('../views/SettingsView.vue')
  }
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/dashboard',
      children: routes
    }
  ]
})

export default router
