<template>
  <div class="search-container" :class="{ 'search-container--compact': compact, 'search-container--header': onHeader }">
    <div class="search-wrapper" :class="{ 'search-wrapper--compact': compact }">
      <div class="custom-search-box" :class="{ 'custom-search-box--compact': compact }">
        <n-icon class="search-icon"><search /></n-icon>
        <input
          :value="searchQuery"
          @input="handleSearchInput"
          :placeholder="compact ? '搜索' : '搜索插件'"
          class="search-input"
        />
        <n-icon 
          v-if="searchQuery"
          class="clear-icon"
          @click="handleClearSearch"
        >
          <close-circle />
        </n-icon>
      </div>
      <n-select
        v-model:value="sortBy"
        :options="compact ? compactSortOptions : sortOptions"
        @update:value="handleSortChange"
        :size="compact ? 'small' : 'medium'"
        class="sort-select"
        :class="{ 'sort-select--compact': compact }"
      />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { NSelect, NIcon } from 'naive-ui'
import { Search, CloseCircle } from '@vicons/ionicons5'

const props = defineProps({
  searchQuery: String,
  currentPage: Number,
  sortBy: String,
  compact: {
    type: Boolean,
    default: false
  },
  onHeader: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:searchQuery', 'update:currentPage', 'update:sortBy'])

const sortOptions = [
  { label: '默认排序', value: 'default' },
  { label: '随机推荐', value: 'random' },
  { label: '按更新时间', value: 'updated' },
  { label: '按 Star 数量', value: 'stars' }
]

const compactSortOptions = [
  { label: '默认', value: 'default' },
  { label: '随机', value: 'random' },
  { label: '时间', value: 'updated' },
  { label: 'Star', value: 'stars' }
]

const sortBy = ref(props.sortBy)

const handleSortChange = (value) => {
  emit('update:sortBy', value)
}

const handleSearchInput = (e) => {
  const value = e.target.value
  emit('update:searchQuery', value)
  // 如果当前页不是第一页，自动重置到第一页
  if (props.currentPage > 1) {
    emit('update:currentPage', 1)
  }
}

const handleClearSearch = () => {
  emit('update:searchQuery', '')
  // 重置到第一页
  if (props.currentPage > 1) {
    emit('update:currentPage', 1)
  }
}
</script>

<style scoped>
/* 搜索框容器 */
.search-container {
  display: flex;
  justify-content: center;
  max-width: 800px;
  margin: 0 auto 16px;
  position: relative;
  z-index: 1;
}

.search-wrapper {
  display: flex;
  width: 100%;
  gap: 12px;
  align-items: center;
}

/* 排序选择器样式 */
.sort-select {
  width: 140px;
  flex-shrink: 0;
}

:deep(.sort-select .n-base-selection) {
  background: transparent !important;
  border: 0px solid rgba(0, 0, 0, 0.08) !important;
  transition: all 0.2s ease !important;
  height: 44px !important;
  border-radius: 12px !important;
  padding: 0 0px !important;
}

:deep(.sort-select .n-base-selection-overlay) {
  background: var(--input-bg) !important;
  border-radius: 12px !important;
  box-shadow: var(--shadow-sm) !important;
  transition: all 0.3s ease !important;
}

:deep(.sort-select .n-base-selection-overlay:hover) {
  background: var(--input-bg-hover) !important;
  box-shadow: var(--shadow-md) !important;
}

:deep(.sort-select .n-base-selection:focus-within .n-base-selection-overlay) {
  background: var(--input-bg-focus) !important;
  box-shadow: var(--shadow-md), 0 0 0 3px rgba(96, 165, 250, 0.2) !important;
}

:deep(.sort-select .n-base-selection-label) {
  color: var(--input-text) !important;
  background: var(--input-bg, rgba(0, 0, 0, 0.03));
  height: 44px !important;
  display: flex !important;
  align-items: center !important;
  padding: 0 12px !important;
  font-weight: 500 !important;
  transition: all 0.2s ease !important;
}

:deep(.sort-select .n-base-selection:hover .n-base-selection-label) {
  background: var(--input-bg-hover) !important;
  color: var(--input-text) !important;
}

:deep(.sort-select .n-base-selection:focus-within .n-base-selection-label) {
  background: var(--input-bg-focus) !important;
  color: var(--primary-color) !important;
}

:deep(.sort-select .n-base-selection-input__content) {
  color: var(--input-text) !important;
  font-weight: 500 !important;
}

:deep(.sort-select .n-base-selection-placeholder) {
  color: var(--input-placeholder) !important;
  font-weight: 400 !important;
  opacity: 0.6;
}

:deep(.sort-select .n-base-selection__border) {
  display: none !important;
}

:deep(.sort-select .n-base-selection__state-border) {
  display: none !important;
}

/* 下拉菜单样式统一 */
:deep(.n-base-select-menu) {
  border-radius: 16px !important;
  padding: 8px !important;
  box-shadow: var(--shadow-lg) !important;
  border: none !important;
  background: var(--input-bg) !important;
  color: var(--input-text) !important;
}

:deep(.n-base-select-option) {
  border-radius: 12px !important;
  margin: 2px 0 !important;
  padding: 8px 12px !important;
  transition: all 0.2s ease !important;
  color: var(--input-text) !important;
}

:deep(.n-base-select-option:hover) {
  background: var(--input-bg-hover) !important;
}

/* 自定义搜索框 - 简洁的单层结构 */
.custom-search-box {
  display: flex;
  align-items: center;
  width: 100%;
  height: 44px;
  background: var(--input-bg, rgba(0, 0, 0, 0.03));
  border: 2px solid rgba(0, 0, 0, 0.08);
  border-radius: 12px;
  transition: all 0.2s ease;
  overflow: hidden;
  padding: 0 16px;
  gap: 12px;
}

.custom-search-box:hover {
  background: var(--input-bg-hover, rgba(0, 0, 0, 0.04));
  border-color: rgba(0, 0, 0, 0.12);
}

.custom-search-box:focus-within {
  background: var(--input-bg-focus, #ffffff);
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px rgba(96, 165, 250, 0.15);
}

/* 搜索图标 */
.search-icon {
  color: var(--input-text);
  font-size: 18px;
  flex-shrink: 0;
  opacity: 0.7;
}

.custom-search-box:focus-within .search-icon {
  color: var(--primary-color);
  opacity: 1;
}

/* 清除按钮 */
.clear-icon {
  color: var(--input-text);
  font-size: 18px;
  flex-shrink: 0;
  opacity: 0.5;
  cursor: pointer;
  transition: all 0.2s ease;
}

.clear-icon:hover {
  opacity: 0.8;
  transform: scale(1.1);
}

.clear-icon:active {
  opacity: 1;
  transform: scale(0.95);
}

/* 搜索输入框 */
.search-input {
  flex: 1;
  height: 100%;
  border: none;
  outline: none;
  background: transparent;
  color: var(--input-text);
  font-size: 16px;
  font-weight: 500;
  padding: 0;
  margin: 0;
}

.search-input::placeholder {
  color: var(--input-placeholder);
  font-weight: 400;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .search-container {
    max-width: 90%;
    margin: 0 auto 12px;
  }
}

@media (max-width: 480px) {
  .search-wrapper {
    flex-direction: column;
    gap: 8px;
    align-items: center;
  }

  .sort-select {
    width: 100%;
  }

  :deep(.sort-select .n-base-selection) {
    height: 40px !important;
    max-width: 120px;
  }

  :deep(.sort-select .n-base-selection-label) {
    height: 40px !important;
  }

  .search-container {
    padding: 0 8px;
    margin-bottom: 12px;
  }
  
  .custom-search-box {
    height: 40px;
    padding: 0 14px;
    gap: 10px;
  }
  
  .search-icon {
    font-size: 16px;
  }
  
  .search-input {
    font-size: 15px;
  }
}

@media (max-width: 360px) {
  .search-container {
    max-width: 80%;
  }
  
  .custom-search-box {
    height: 36px;
    padding: 0 10px;
    gap: 8px;
  }
  
  .search-icon {
    font-size: 15px;
  }
  
  .search-input {
    font-size: 13px;
  }
}

@media (hover: none) and (pointer: coarse) {
  .custom-search-box:hover {
    background: var(--input-bg);
    border-color: var(--input-border);
    box-shadow: var(--shadow-sm);
  }
}

/* ===== Compact 模式样式 ===== */
.search-container--compact {
  margin: 0;
  max-width: 100%;
}

.search-wrapper--compact {
  gap: 8px;
}

.custom-search-box--compact {
  height: 36px;
  padding: 0 12px;
  gap: 8px;
  border-radius: 8px;
  background: var(--bg-card);
  border: 2px solid var(--border-base);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  box-shadow: none;
}

.custom-search-box--compact .search-icon {
  font-size: 16px;
  color: var(--text-secondary);
}

.custom-search-box--compact .search-input {
  font-size: 14px;
  color: var(--text-secondary);
}

.custom-search-box--compact .search-input::placeholder {
  color: var(--text-tertiary);
  opacity: 0.8;
}

.custom-search-box--compact .clear-icon {
  font-size: 16px;
  color: var(--text-secondary);
}

.sort-select--compact {
  width: 80px;
}

:deep(.sort-select--compact .n-base-selection) {
  height: 36px !important;
  background: var(--bg-card) !important;
  border: 2px solid var(--border-base) !important;
  border-radius: 8px !important;
  backdrop-filter: blur(10px) !important;
  -webkit-backdrop-filter: blur(10px) !important;
  box-shadow: none !important;
}

:deep(.sort-select--compact .n-base-selection:hover) {
  background: var(--bg-hover) !important;
  border-color: var(--primary-color) !important;
}

:deep(.sort-select--compact .n-base-selection:focus-within) {
  background: var(--bg-card) !important;
  border-color: var(--primary-color) !important;
  box-shadow: none !important;
}

:deep(.sort-select--compact .n-base-selection-label) {
  height: 36px !important;
  font-size: 13px !important;
  color: var(--text-secondary) !important;
  background: var(--bg-card) !important;
  padding: 0 8px !important;
}

/* Ensure compact input content matches search text color */
:deep(.sort-select--compact .n-base-selection-input__content) {
  color: var(--text-secondary) !important;
}
:deep(.sort-select--compact .n-base-selection-placeholder) {
  color: var(--text-tertiary) !important;
}

:deep(.sort-select--compact .n-base-selection-overlay) {
  background: var(--bg-card) !important;
  box-shadow: none !important;
}

/* 深色主题下的 compact 模式样式已通过 CSS 变量自动适配 */
/* ===== Overrides: keep transparent look in full header, theme-aware text ===== */
.search-container--header :deep(.sort-select .n-base-selection-overlay) {
  background: var(--input-bg) !important;
}
.search-container--header :deep(.sort-select .n-base-selection-overlay:hover) {
  background: var(--input-bg-hover) !important;
}
.search-container--header :deep(.sort-select .n-base-selection:focus-within .n-base-selection-overlay) {
  background: var(--input-bg-focus) !important;
}

.search-container--header :deep(.sort-select .n-base-selection-label) {
  color: var(--input-text) !important;
  background: var(--input-bg) !important;
}
.search-container--header :deep(.sort-select .n-base-selection:hover .n-base-selection-label) {
  background: var(--input-bg-hover) !important;
  color: var(--input-text) !important;
}
.search-container--header :deep(.sort-select .n-base-selection:focus-within .n-base-selection-label) {
  background: var(--input-bg-focus) !important;
}
.search-container--header :deep(.sort-select .n-base-selection-input__content) {
  color: var(--input-text) !important;
}
.search-container--header :deep(.sort-select .n-base-selection-placeholder) {
  color: var(--input-placeholder) !important;
}

.search-container--header .custom-search-box {
  background: var(--input-bg) !important;
  border-color: var(--input-border) !important;
}
.search-container--header .custom-search-box:hover {
  background: var(--input-bg-hover) !important;
  border-color: var(--input-border-hover) !important;
}
.search-container--header .custom-search-box:focus-within {
  background: var(--input-bg-focus) !important;
}

.search-container--header :deep(.n-base-select-menu) {
  background: var(--input-bg) !important;
  color: var(--text-primary) !important;
}
.search-container--header :deep(.n-base-select-option:hover) {
  background: var(--input-bg-hover) !important;
}

/* Compact: ensure visible border in sticky header */
.search-container--compact .custom-search-box {
  border: 2px solid var(--border-base);
}

/* Strengthen compact hover/focus border color */
.custom-search-box--compact:hover {
  background: var(--bg-hover);
  border-color: var(--primary-color) !important;
}
.custom-search-box--compact:focus-within {
  background: var(--bg-card);
  border-color: var(--primary-color) !important;
  box-shadow: none;
}

/* Final color overrides to ensure correctness */
/* Full header: white-like text via input variables */
.search-container--header :deep(.n-base-selection-input__content),
.search-container--header :deep(.n-base-selection-label) {
  color: var(--input-text) !important;
}
.search-container--header :deep(.n-base-selection-placeholder) {
  color: var(--input-placeholder) !important;
}

/* Compact: softer gray text to match search */
.search-container--compact :deep(.n-base-selection-input__content),
.search-container--compact :deep(.n-base-selection-label) {
  color: var(--text-secondary) !important;
}
.search-container--compact :deep(.n-base-selection-placeholder) {
  color: var(--text-tertiary) !important;
}

/* Full header: borderless search box */
.search-container--header .custom-search-box {
  border: none !important;
}
.search-container--header .custom-search-box:hover {
  border: none !important;
}
.search-container--header .custom-search-box:focus-within {
  border: none !important;
}
</style>
