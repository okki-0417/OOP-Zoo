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
      path: "/zoo",
      name: "zoo",
      component: () => import("./views/ZooMapView.vue"),
      meta: { section: "zoo" },
    },
    {
      path: "/zoo/staff",
      name: "staff",
      component: () => import("./views/StaffHouseView.vue"),
      meta: { section: "zoo" },
    },
    {
      path: "/zoo/gate",
      name: "gate",
      component: () => import("./views/GateView.vue"),
      meta: { section: "zoo" },
    },
    {
      path: "/enclosures/:id",
      name: "enclosure",
      component: () => import("./views/EnclosureView.vue"),
      props: true,
      meta: { section: "zoo" },
    },
    {
      path: "/animals/:id",
      name: "animal",
      component: () => import("./views/AnimalView.vue"),
      props: true,
      meta: { section: "zoo" },
    },
    { path: "/animals", redirect: "/zoo" },
    { path: "/enclosures", redirect: "/zoo" },
    { path: "/work", redirect: "/zoo/staff" },
    { path: "/staff", redirect: "/zoo/staff" },
  ],
  scrollBehavior: () => ({ top: 0 }),
});
