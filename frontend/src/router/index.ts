import { createRouter, createWebHistory, type RouteRecord, type RouteRecordNormalized } from 'vue-router'
import DashboardView from '../views/DashboardView.vue'
import AdminView from '../views/AdminView.vue'

const routes = [
  {
    path: '',
    name: 'dashboard',
    component: DashboardView
  }
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/dashboard',
      children: routes
    },
    {
      path: '/admin',
      component: AdminView
    }
  ]
})

export default router
