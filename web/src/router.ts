import { createRouter, createWebHistory } from "vue-router";

export const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: "/",
      name: "office",
      component: () => import("./views/OfficeView.vue"),
      meta: { section: "office" },
    },
    {
      path: "/reputation",
      name: "reputation",
      component: () => import("./views/ReputationView.vue"),
      meta: { section: "office" },
    },
    {
      path: "/animals",
      name: "animals",
      component: () => import("./views/AnimalsView.vue"),
      meta: { section: "animals" },
    },
    {
      path: "/animals/:id",
      name: "animal",
      component: () => import("./views/AnimalView.vue"),
      props: true,
      meta: { section: "animals" },
    },
    {
      path: "/enclosures",
      name: "enclosures",
      component: () => import("./views/EnclosuresView.vue"),
      meta: { section: "enclosures" },
    },
    {
      path: "/enclosures/:id",
      name: "enclosure",
      component: () => import("./views/EnclosureView.vue"),
      props: true,
      meta: { section: "enclosures" },
    },
    {
      path: "/staff",
      name: "staff",
      component: () => import("./views/StaffView.vue"),
      meta: { section: "staff" },
    },
    { path: "/zoo", redirect: "/enclosures" },
    { path: "/zoo/gate", redirect: "/animals" },
    { path: "/zoo/staff", redirect: "/staff" },
    { path: "/work", redirect: "/staff" },
  ],
  scrollBehavior: () => ({ top: 0 }),
});
