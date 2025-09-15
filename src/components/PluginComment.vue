// 评论部分已弃用

<template>
  <div class="plugin-comment">
    <div class="plugin-comment__header">
    </div>
    <div
      class="giscus"
      ref="giscusRef"
    ></div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, nextTick } from 'vue'

const props = defineProps({
  repo: {
    type: String,
    required: true
  },
  theme: {
    type: String,
    default: 'light'
  },
  pluginName: {
    type: String,
    required: true
  }
})

const giscusRef = ref(null)

// 加载 Giscus
function loadGiscus() {
  if (!giscusRef.value) return

  const iframe = giscusRef.value.querySelector('iframe')
  if (iframe) {
    iframe.remove()
  }

  const script = document.createElement('script')
  script.src = 'https://giscus.app/client.js'
  script.setAttribute('data-repo', 'IGCrystal-NEO/Astrbot_Plugins_Market')
  script.setAttribute('data-repo-id', 'R_kgDOPRLyzg')
  script.setAttribute('data-category', 'Ideas')
  script.setAttribute('data-category-id', 'DIC_kwDOPRLyzs4CthUw')
  script.setAttribute('data-mapping', 'specific')
  script.setAttribute('data-term', `plugin:${props.pluginName}`)
  script.setAttribute('data-strict', '1')
  script.setAttribute('data-reactions-enabled', '1')
  script.setAttribute('data-emit-metadata', '0')
  script.setAttribute('data-input-position', 'bottom')
  script.setAttribute('data-theme', props.theme === 'dark' ? 'dark_tritanopia' : 'light_tritanopia')
  script.setAttribute('data-lang', 'zh-CN')
  script.setAttribute('data-loading', 'lazy')
  script.crossOrigin = 'anonymous'
  script.async = true

  giscusRef.value.appendChild(script)
}

watch(() => props.theme, () => {
  loadGiscus()
})

const updateGiscusTheme = (theme) => {
  const iframe = document.querySelector('.giscus-frame')
  if (!iframe) return
  
  iframe.contentWindow.postMessage({
    giscus: {
      setConfig: {
        theme: theme === 'dark' ? 'dark_tritanopia' : 'light_tritanopia'
      }
    }
  }, 'https://giscus.app')
}

onMounted(() => {
  loadGiscus()
})

watch(() => props.theme, (newTheme) => {
  nextTick(() => {
    updateGiscusTheme(newTheme)
  })
}, { immediate: false })
</script>

<style scoped>
.plugin-comment {
  margin: var(--modal-padding) calc(-1 * var(--modal-padding));
  padding: var(--modal-padding);
  border-top: 1px solid var(--n-border-color);
  background-color: var(--n-color);
}

.plugin-comment__header {
  margin-bottom: 16px;
}

.plugin-comment__header :deep(h3) {
  margin: 0;
}

.giscus {
  margin-top: 16px;
}
</style>
