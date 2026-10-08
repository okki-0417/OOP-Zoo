<template>
  <div class="stage">
    <div class="screen">
      <slot />
    </div>
    <p class="rotate-prompt"><span class="icon">📱</span>横向きにしてください</p>
  </div>
</template>

<style scoped>
.stage {
  display: grid;
  place-items: center;
  height: 100dvh;
  background: var(--surface-sunk);
}

.screen {
  container: screen / size;
  contain: layout paint;
  overflow-y: auto;
  width: 100dvw;
  height: 100dvh;
  padding-inline: env(safe-area-inset-left) env(safe-area-inset-right);
  background: var(--bg);
}

.rotate-prompt {
  display: none;
  gap: 12px;
  justify-items: center;
  font-weight: 800;
  color: var(--ink-soft);
}

.rotate-prompt .icon {
  font-size: 3rem;
  rotate: 90deg;
}

@media (hover: hover) and (pointer: fine) {
  .screen {
    width: 844px;
    height: 390px;
    border-radius: 24px;
    box-shadow:
      0 0 0 10px #111,
      0 24px 48px rgb(0 0 0 / 25%);
  }
}

@media (orientation: portrait) and (pointer: coarse) {
  .screen {
    display: none;
  }

  .rotate-prompt {
    display: grid;
  }
}
</style>
