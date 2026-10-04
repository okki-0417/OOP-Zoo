import { createRouter, createWebHistory } from "vue-router";

export const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: "/", name: "office", component: () => import("./views/OfficeView.vue") },
    { path: "/animals", name: "animals", component: () => import("./views/AnimalsView.vue") },
    {
      path: "/animals/:id",
      name: "animal",
      component: () => import("./views/AnimalView.vue"),
      props: true,
    },
    {
      path: "/enclosures",
      name: "enclosures",
      component: () => import("./views/EnclosuresView.vue"),
    },
    {
      path: "/enclosures/:id",
      name: "enclosure",
      component: () => import("./views/EnclosureView.vue"),
      props: true,
    },
    { path: "/staff", name: "staff", component: () => import("./views/StaffView.vue") },
  ],
  scrollBehavior: () => ({ top: 0 }),
});
