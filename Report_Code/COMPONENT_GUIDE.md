<!-- OLAP Web Interface - Component Documentation -->

# React Components Structure

## Component Tree

```
<App> (Main Container)
  ├── <Header>
  │   └── Title & Description
  │
  └── <Container>
      ├── <Row>
      │   ├── <Col-md-3> (Sidebar)
      │   │   ├── <CubeSelector>
      │   │   │   ├── Card Header
      │   │   │   ├── Cube List (Buttons)
      │   │   │   └── Selection Handler
      │   │   │
      │   │   └── <OLAPOperations>
      │   │       ├── Card Header
      │   │       ├── Dimension Select
      │   │       ├── Operation Buttons
      │   │       │   ├── Drill Down
      │   │       │   ├── Roll Up
      │   │       │   ├── Slice & Dice
      │   │       │   └── Pivot
      │   │       ├── Info Alert
      │   │       └── Operation Handlers
      │   │
      │   └── <Col-md-9> (Main Content)
      │       └── <DataViewer>
      │           ├── Operation Badge
      │           ├── <BarChart> (Recharts)
      │           ├── <Table>
      │           │   ├── <thead>
      │           │   │   └── Headers
      │           │   └── <tbody>
      │           │       └── Rows
      │           ├── Pivot Table (when needed)
      │           └── Metadata Info
      │
      └── <Footer>
          └── Info & Links
```

---

## Component Details

### 1. App.js (Main Component)

**Props**: None (uses internal state)

**State**:
```javascript
{
  selectedCube: 'sales_cube',
  cubes: [],
  data: {},
  loading: false,
  activeOperation: null
}
```

**Functions**:
- `fetchCubes()` - Load available cubes
- `handleCubeChange(cubeName)` - Switch cube
- `fetchData(cube)` - Get cube data
- `handleOperation(type, data)` - Execute OLAP operation

**Renders**:
- Header
- Sidebar with CubeSelector & OLAPOperations
- Main content area with DataViewer

---

### 2. CubeSelector.js

**Props**:
```javascript
{
  cubes: Array,                    // List of cubes
  selectedCube: String,            // Currently selected cube
  onCubeChange: Function,          // Callback when cube changes
  loading: Boolean                 // Loading state
}
```

**Renders**:
- Card with list of cube buttons
- Visual indicator for selected cube
- Disabled state during loading

**Features**:
- Button group vertical layout
- Bootstrap styling
- Loading state management

---

### 3. OLAPOperations.js

**Props**:
```javascript
{
  onOperation: Function,           // Callback for operations
  activeOperation: String,         // Currently active operation
  loading: Boolean                 // Loading state
}
```

**State**:
```javascript
{
  drillDownLevel: Number,          // Current drill down level
  selectedDimension: String        // Selected dimension
}
```

**Functions**:
- `handleDrillDown()` - Execute drill down
- `handleRollUp()` - Execute roll up
- `handleSliceDice()` - Execute slice & dice
- `handlePivot()` - Execute pivot

**Renders**:
- Card with operation controls
- Dimension selector dropdown
- 4 operation buttons
- Info alert explaining operations

**Features**:
- Level tracking
- Disabled/enabled button logic
- Active state styling
- Helpful tooltips

---

### 4. DataViewer.js

**Props**:
```javascript
{
  data: Object,                    // Result data from API
  loading: Boolean,                // Loading state
  activeOperation: String          // Current operation
}
```

**Functions**:
- `renderChart()` - Render bar chart
- `renderTable()` - Render data table
- `renderPivotTable()` - Render pivot table
- `getOperationBadge()` - Get operation badge

**Renders**:
- Operation badge
- Bar chart (using Recharts)
- Data table (HTML table)
- Pivot table (special format)
- Metadata info

**Features**:
- Multiple visualization options
- Responsive design
- Loading spinner
- Error/empty state handling

---

## State Management Flow

```
User Action (e.g., click Drill Down)
    ↓
OLAPOperations.handleDrillDown()
    ↓
Call App.handleOperation('drill-down', data)
    ↓
App calls API via axios
    ↓
API returns data
    ↓
App updates state (data, activeOperation)
    ↓
Re-render:
  - OLAPOperations (activeOperation)
  - DataViewer (data, activeOperation)
    ↓
User sees updated table/chart
```

---

## Props Passing Strategy

### App → CubeSelector
```javascript
cubes={cubes}
selectedCube={selectedCube}
onCubeChange={handleCubeChange}
loading={loading}
```

### App → OLAPOperations
```javascript
onOperation={handleOperation}
activeOperation={activeOperation}
loading={loading}
```

### App → DataViewer
```javascript
data={data}
loading={loading}
activeOperation={activeOperation}
```

---

## Styling Strategy

### CSS Classes Used

**App Level**:
- `.App` - Main container
- `.container-fluid` - Bootstrap fluid container
- `.row` - Bootstrap row
- `.col-md-3`, `.col-md-9` - Bootstrap columns

**Components**:
- `.card` - Card container
- `.card-header` - Card header
- `.card-body` - Card body
- `.btn-operation` - Operation buttons
- `.btn-operation.active` - Active button state
- `.data-table` - Data table container
- `.chart-container` - Chart wrapper
- `.table`, `.table-hover` - Bootstrap table
- `.loading-spinner` - Loading indicator
- `.operation-badge` - Operation indicator

**Bootstrap Components Used**:
- Buttons (`.btn`, `.btn-primary`, `.btn-info`, etc.)
- Form Controls (`.form-select`, `.form-label`)
- Tables (`.table`, `.table-responsive`)
- Alerts (`.alert`, `.alert-info`)
- Badges (`.badge`)
- Spinners (`.spinner-border`)

---

## Event Handlers

### App.js
- `useEffect()` - Fetch cubes on mount
- `handleCubeChange()` - When user selects cube
- `handleOperation()` - When user clicks OLAP operation

### CubeSelector.js
- `onClick` on cube buttons - Trigger cube selection

### OLAPOperations.js
- `onChange` on dimension selector - Update selected dimension
- `onClick` on operation buttons - Execute operation

### DataViewer.js
- Recharts handlers (built-in chart interactions)

---

## API Calls (axios)

### Endpoints Called

**In App.js**:
```javascript
// Get cubes list
axios.get('/api/cubes')

// Query data
axios.post('/api/query', { cube, mdxQuery })

// Execute operations
axios.post('/api/operations/drill-down', { cube, dimension, currentLevel })
axios.post('/api/operations/roll-up', { cube, dimension, currentLevel })
axios.post('/api/operations/slice-dice', { cube, filters })
axios.post('/api/operations/pivot', { cube, rows, columns, measures })
```

---

## Performance Optimizations

1. **Memoization**: Consider using `React.memo()` for components
2. **useCallback**: Memoize callbacks to prevent unnecessary re-renders
3. **useMemo**: Cache expensive calculations
4. **Lazy Loading**: Load charts only when visible

Example:
```javascript
const CubeSelector = React.memo(({ cubes, selectedCube, onCubeChange, loading }) => {
  // Component code
});

const memoizedHandleOperation = useCallback((type, data) => {
  handleOperation(type, data);
}, []);
```

---

## Error Handling

**Locations**:
1. `App.js` - Try/catch in axios calls
2. `DataViewer.js` - Handle empty/null data
3. `CubeSelector.js` - Show loading state
4. `OLAPOperations.js` - Disable buttons when needed

**User Feedback**:
- Loading spinner while fetching
- Error messages in alerts
- Empty state messages
- Toast notifications (future enhancement)

---

## Testing Strategies

### Unit Tests (Jest + React Testing Library)

```javascript
// Test CubeSelector
test('renders cube buttons', () => {
  render(<CubeSelector cubes={cubes} ... />);
  expect(screen.getByText('sales_cube')).toBeInTheDocument();
});

// Test OLAPOperations
test('drill down button is enabled', () => {
  render(<OLAPOperations ... />);
  const button = screen.getByRole('button', { name: /drill down/i });
  expect(button).not.toBeDisabled();
});
```

### Integration Tests

- Test data flow from click to display
- Test API calls and responses
- Test state updates

### E2E Tests (Cypress)

- Test complete user workflows
- Test OLAP operations end-to-end
- Test different browsers

---

## Future Enhancements

1. **useReducer**: Replace useState for complex state
2. **Context API**: Global state management
3. **React Query**: Better data fetching
4. **TypeScript**: Type safety
5. **Storybook**: Component documentation
6. **Dark Mode**: Theme switching
7. **Internationalization**: Multi-language support
8. **Advanced Charting**: More chart types
9. **Export Data**: CSV, Excel export
10. **Bookmarks**: Save favorite queries

---

## Browser Compatibility

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+
- Mobile browsers (iOS Safari 14+, Chrome Android)

---

## Accessibility (a11y)

Features implemented:
- ARIA labels on buttons
- Semantic HTML
- Keyboard navigation
- Color contrast ratios
- Loading state announcements

---

## Code Organization

```
client/src/
├── components/
│   ├── CubeSelector.js
│   ├── OLAPOperations.js
│   └── DataViewer.js
├── App.js
├── App.css
└── index.js
```

---

Last Updated: 2024-05-04
