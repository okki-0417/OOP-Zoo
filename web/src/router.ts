import { createRouter, createWebHistory } from "vue-router";

export const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: "/",
      name: "office",
      component: () => import("./views/OfficeView.vue"),
      meta: { section: "office" },
      children: [
        { path: "chores", name: "chores", component: () => import("./views/ChoresView.vue") },
        {
          path: "reputation",
          name: "reputation",
          component: () => import("./views/ReputationView.vue"),
        },
        { path: "finance", name: "finance", component: () => import("./views/FinanceView.vue") },
        {
          path: "threatened",
          name: "threatened",
          component: () => import("./views/ThreatenedView.vue"),
        },
        { path: "memorial", name: "memorial", component: () => import("./views/MemorialView.vue") },
      ],
    },
    {
      path: "/animals",
      name: "animals",
      component: () => import("./views/AnimalsView.vue"),
      meta: { section: "animals" },
      children: [
        {
          path: "new",
          name: "acquire-animal",
          component: () => import("./views/AcquireAnimalView.vue"),
        },
        {
          path: ":id",
          name: "animal",
          component: () => import("./views/AnimalView.vue"),
          props: true,
        },
      ],
    },
    {
      path: "/enclosures",
      name: "enclosures",
      component: () => import("./views/EnclosuresView.vue"),
      meta: { section: "enclosures" },
      children: [
        {
          path: "new",
          name: "build-enclosure",
          component: () => import("./views/BuildEnclosureView.vue"),
        },
        {
          path: ":id",
          name: "enclosure",
          component: () => import("./views/EnclosureView.vue"),
          props: true,
        },
      ],
    },
    {
      path: "/staff",
      name: "staff",
      component: () => import("./views/StaffView.vue"),
      meta: { section: "staff" },
      children: [
        { path: "new", name: "hire-staff", component: () => import("./views/HireStaffView.vue") },
        { path: "rounds", name: "rounds", component: () => import("./views/RoundsView.vue") },
        {
          path: ":id",
          name: "keeper",
          component: () => import("./views/KeeperView.vue"),
          props: true,
        },
      ],
    },
    { path: "/zoo", redirect: "/enclosures" },
    { path: "/zoo/gate", redirect: "/animals" },
    { path: "/zoo/staff", redirect: "/staff" },
    { path: "/work", redirect: "/staff" },
  ],
  scrollBehavior: () => ({ top: 0 }),
});
