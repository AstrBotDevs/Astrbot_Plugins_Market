<template>
  <n-modal
    v-model:show="show"
    :mask-closable="true"
    preset="card"
    class="plugin-details"
    style="max-width: 900px; width: 90%"
    :bordered="false"
  >
    <template #header>
      <div class="plugin-details__header">
        <n-h2 class="plugin-details__title">
          <n-space align="center" :size="12">
            <n-icon size="24">
              <extension-puzzle-outline />
            </n-icon>
            {{ plugin?.name }}
            <n-tag type="success" size="small" :bordered="false">
              {{ plugin?.version?.startsWith('v') ? plugin?.version : 'v' + plugin?.version }}
            </n-tag>
          </n-space>
        </n-h2>
      </div>
    </template>

    <div class="plugin-details__content">
      <n-space vertical size="large">
        <!-- README 内容 -->
        <div v-if="loading" class="readme-loading">
          <n-spin size="medium">
            <template #description>
              正在加载 README...
            </template>
          </n-spin>
        </div>
        <div v-else-if="error" class="readme-error">
          <n-empty description="加载 README 失败">
            <template #extra>
              <n-button size="small" @click="fetchReadme">
                重试
              </n-button>
            </template>
          </n-empty>
        </div>
        <div v-else class="markdown-content" v-html="readmeHtml"></div>

        
      </n-space>
    </div>

    <template #footer>
      <div class="plugin-details__footer">
        <n-space justify="end" :size="12">
          <n-button
            secondary
            type="primary"
            @click="openUrl(plugin?.repo)"
          >
            <template #icon>
              <n-icon><logo-github /></n-icon>
            </template>
            查看仓库
          </n-button>
          <n-button
            type="primary"
            @click="show = false"
          >
            关闭
          </n-button>
        </n-space>
      </div>
    </template>
  </n-modal>
</template>

<script setup>
import { ref, watch } from 'vue'
import { marked } from 'marked'
import {
  NModal,
  NSpace,
  NH2,
  NIcon,
  NTag,
  NButton,
  NSpin,
  NEmpty
} from 'naive-ui'
import { storeToRefs } from 'pinia'
import { usePluginStore } from '../stores/plugins'
import {
  ExtensionPuzzleOutline,
  LogoGithub
} from '@vicons/ionicons5'

const props = defineProps({
  show: Boolean,
  plugin: Object
})

const emit = defineEmits(['update:show'])

const show = ref(props.show)
const loading = ref(false)
const error = ref(false)
const readmeHtml = ref('')

// 获取全局主题状态
const store = usePluginStore()
const { isDarkMode } = storeToRefs(store)

watch(() => props.show, (newVal) => {
  show.value = newVal
})

watch(show, (newVal) => {
  emit('update:show', newVal)
  if (newVal) {
    fetchReadme()
  }
})

const openUrl = (url) => {
  if (url) {
    window.open(url, '_blank')
  }
}

async function fetchReadme() {
  if (!props.plugin?.repo) return
  
  loading.value = true
  error.value = false
  
  try {
    const [owner, repo] = props.plugin.repo.split('/').slice(-2)

    let readmeText = ''

    try {
      const apiResp = await fetch(`https://api.github.com/repos/${owner}/${repo}/readme`, {
        method: 'GET',
        headers: {
          'Accept': 'application/vnd.github.v3.raw'
        },
        timeout: 10000
      })

      if (apiResp.ok) {
        readmeText = await apiResp.text()
      } else {
        throw new Error(`GitHub API /readme returned ${apiResp.status}`)
      }
    } catch (apiErr) {
      const branches = ['main', 'master']
      const candidates = ['README.md', 'Readme.md', 'readme.md', 'README.MD', 'README']

      let found = false
      for (const branch of branches) {
        for (const filename of candidates) {
          try {
            const resp = await fetch(`https://github.wenturc.com/${owner}/${repo}/${branch}/${filename}`, {
              method: 'GET',
              headers: {
                'Accept': 'text/plain'
              },
              timeout: 10000
            })
            if (resp.ok) {
              readmeText = await resp.text()
              found = true
              break
            }
          } catch (_) {
            // 忽略，尝试下一个候选
          }
        }
        if (found) break
      }

      if (!found) {
        throw new Error('无法获取 README（API 与镜像均失败）')
      }
    }

    if (!readmeText) {
      throw new Error('README 内容为空')
    }

    readmeHtml.value = marked(readmeText)
  } catch (err) {
    console.error('Error fetching README:', err)
    error.value = true
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.plugin-details {
  --modal-padding: 24px !important;
}

.plugin-details :deep(.n-modal) {
  max-height: 90vh !important;
}

.plugin-details__header {
  padding: 0 var(--modal-padding);
  margin: calc(-1 * var(--modal-padding)) calc(-1 * var(--modal-padding)) 0;
  padding-top: var(--modal-padding);
  padding-bottom: 16px;
  border-bottom: 1px solid var(--n-border-color);
}

.plugin-details__title {
  margin: 0;
  display: flex;
  align-items: center;
  gap: 12px;
}

.plugin-details__content {
  padding: var(--modal-padding) 0;
  padding-right: 16px;
  margin-right: 4px;
  overflow-y: auto;
  max-height: calc(80vh - 180px);
}

.markdown-content {
  color: var(--n-text-color-2);
  line-height: 1.6;
}

.markdown-content :deep(h1),
.markdown-content :deep(h2),
.markdown-content :deep(h3),
.markdown-content :deep(h4),
.markdown-content :deep(h5),
.markdown-content :deep(h6) {
  margin: 1.5em 0 0.5em;
  color: var(--n-text-color);
}

.markdown-content :deep(h1:first-child),
.markdown-content :deep(h2:first-child),
.markdown-content :deep(h3:first-child) {
  margin-top: 0;
}

.markdown-content :deep(p) {
  margin: 1em 0;
}

.markdown-content :deep(img) {
  max-width: 100%;
  border-radius: 8px;
}

.markdown-content :deep(code) {
  background: var(--n-code-color);
  padding: 0.2em 0.4em;
  border-radius: 3px;
  font-size: 0.9em;
  font-family: monospace;
}

.markdown-content :deep(pre) {
  background: var(--n-code-color);
  padding: 16px;
  border-radius: 8px;
  overflow-x: auto;
}

.markdown-content :deep(pre code) {
  background: none;
  padding: 0;
  border-radius: 0;
}

.markdown-content :deep(blockquote) {
  margin: 1em 0;
  padding-left: 1em;
  border-left: 4px solid var(--n-border-color);
  color: var(--n-text-color-3);
}

.markdown-content :deep(ul),
.markdown-content :deep(ol) {
  padding-left: 2em;
  margin: 1em 0;
}

.markdown-content :deep(table) {
  border-collapse: collapse;
  width: 100%;
  margin: 1em 0;
}

.markdown-content :deep(th),
.markdown-content :deep(td) {
  border: 1px solid var(--n-border-color);
  padding: 8px;
  text-align: left;
}

.markdown-content :deep(th) {
  background: var(--n-color-hover);
}

.plugin-details__footer {
  padding: var(--modal-padding);
  margin: 0 calc(-1 * var(--modal-padding));
  margin-top: calc(-1 * var(--modal-padding));
  border-top: 0px solid var(--n-border-color);
}

.readme-loading,
.readme-error {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 200px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .plugin-details__content {
    max-height: calc(80vh - 140px);
  }
}

@media (max-width: 480px) {
  .plugin-details {
    --modal-padding: 16px;
  }
  
  .plugin-details__title {
    font-size: 1.2em;
  }
}
</style>
