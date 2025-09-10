export const lightThemeOverrides = {
  'common': { 
    duration: '0.2s',
    borderRadius: '8px',
    primaryColor: '#3b82f6',
    primaryColorHover: '#60a5fa',
    primaryColorPressed: '#2563eb',
    baseColor: '#fff',
    textColor2: '#1e293b',
    textColor3: '#64748b'
  },
  'InternalSelection': {
    textColor: '#1e293b',
    placeholderColor: '#64748b'
  },
  'Pagination': {
    itemTextColor: '#fff',
    itemColorHover: 'rgba(255, 255, 255, 0.1)',
    itemColorPressed: 'rgba(255, 255, 255, 0.2)',
    itemColorActive: 'rgba(255, 255, 255, 0.2)',
    itemBorderRadius: '6px'
  },
  'Tag': {
    borderRadius: '6px'
  },
  'Input': {
    borderHover: '#60a5fa',
    borderFocus: '#3b82f6'
  },
  'Card': {
    borderRadius: '16px',
    color: '#ffffff',
    colorModal: '#ffffff'
  },
  'Select': {
    peers: {
      InternalSelection: {
        textColor: '#1e293b',
        placeholderColor: '#64748b',
        color: 'rgba(255, 255, 255, 0.9)',
        colorActive: 'rgba(255, 255, 255, 0.95)',
        border: '1px solid #e2e8f0',
        borderHover: '1px solid #3b82f6',
        borderActive: '1px solid #3b82f6',
        borderFocus: '1px solid #3b82f6'
      },
      InternalSelectMenu: {
        color: '#ffffff',
        optionTextColor: '#1e293b',
        optionColorHover: '#f8fafc',
        optionColorActive: '#e0f2fe',
        optionTextColorActive: '#0369a1'
      }
    }
  },
  'Button': {
    borderRadius: '8px',
    paddingMedium: '0 18px',
    heightMedium: '34px',
    textColorPrimary: '#ffffff',
    textColorHoverPrimary: '#ffffff',
    textColorQuaternary: '#1e293b',
    textColorQuaternaryHover: '#1e293b',
    textColorQuaternaryPressed: '#1e293b',
    colorQuaternary: 'transparent',
    colorQuaternaryHover: 'rgba(0, 0, 0, 0.05)',
    colorQuaternaryPressed: 'rgba(0, 0, 0, 0.1)'
  }
}
