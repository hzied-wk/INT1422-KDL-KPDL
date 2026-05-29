import React, { useState } from 'react';

function OLAPOperations({ onOperation, activeOperation, loading }) {
  const [drillDownLevel, setDrillDownLevel] = useState(0);
  
  // State cho Slice (1 chiều)
  const [sliceDim, setSliceDim] = useState('DIM_THOIGIAN');
  const [sliceVal, setSliceVal] = useState('');

  // State cho Dice (Đa chiều)
  const [diceDim1, setDiceDim1] = useState('DIM_MATHANG');
  const [diceVal1, setDiceVal1] = useState('');
  const [diceDim2, setDiceDim2] = useState('DIM_KHACHHANG');
  const [diceVal2, setDiceVal2] = useState('');

  const dimensions = ['DIM_MATHANG', 'DIM_THOIGIAN', 'DIM_KHACHHANG'];

  const handleDrillDown = () => {
    onOperation('drill-down', {
      dimension: sliceDim, 
      currentLevel: drillDownLevel
    });
    setDrillDownLevel(drillDownLevel + 1);
  };

  const handleRollUp = () => {
    if (drillDownLevel > 0) {
      onOperation('roll-up', {
        dimension: sliceDim,
        currentLevel: drillDownLevel
      });
      setDrillDownLevel(drillDownLevel - 1);
    }
  };

  const handleSlice = () => {
    onOperation('slice', {
      filters: { [sliceDim]: sliceVal }
    });
  };

  const handleDice = () => {
    const filters = {};
    if (diceVal1) filters[diceDim1] = diceVal1;
    if (diceVal2) filters[diceDim2] = diceVal2;
    onOperation('dice', { filters });
  };

  const handlePivot = () => {
    onOperation('pivot', {
      rows: ['DIM_MATHANG'],
      columns: ['DIM_THOIGIAN'],
      measures: ['Amount']
    });
  };

  return (
    <div className="card">
      <div className="card-header bg-dark text-white">
        ⚙️ OLAP Operations
      </div>
      <div className="card-body" style={{ maxHeight: '700px', overflowY: 'auto' }}>
        
        {/* Drill Down / Roll Up Section */}
        <div className="mb-4 p-2 border rounded bg-light">
          <h6>🔍 Khám phá (Drill/Roll)</h6>
          <select className="form-select form-select-sm mb-2" value={sliceDim} onChange={(e) => setSliceDim(e.target.value)} disabled={loading}>
            {dimensions.map(dim => <option key={dim} value={dim}>{dim}</option>)}
          </select>
          <div className="d-flex gap-2">
            <button className={`btn btn-sm btn-info flex-grow-1 ${activeOperation === 'drill-down' ? 'active' : ''}`} onClick={handleDrillDown} disabled={loading}>
              Drill Down <small>{drillDownLevel > 0 && `(Lvl: ${drillDownLevel})`}</small>
            </button>
            <button className={`btn btn-sm btn-warning flex-grow-1 ${activeOperation === 'roll-up' ? 'active' : ''}`} onClick={handleRollUp} disabled={loading || drillDownLevel === 0}>
              Roll Up
            </button>
          </div>
        </div>

        {/* Slice Section */}
        <div className="mb-4 p-2 border rounded border-primary">
          <h6 className="text-primary">🔪 Slice (Cắt lát)</h6>
          <small className="text-muted d-block mb-2">Cố định 1 chiều dữ liệu duy nhất.</small>
          <div className="input-group input-group-sm mb-2">
            <select className="form-select" style={{maxWidth: '120px'}} value={sliceDim} onChange={(e) => setSliceDim(e.target.value)} disabled={loading}>
              {dimensions.map(dim => <option key={dim} value={dim}>{dim}</option>)}
            </select>
            <input type="text" className="form-control" placeholder="Giá trị (VD: 2023)..." value={sliceVal} onChange={e => setSliceVal(e.target.value)} disabled={loading} />
          </div>
          <button className={`btn btn-sm btn-primary w-100 ${activeOperation === 'slice' ? 'active' : ''}`} onClick={handleSlice} disabled={loading || !sliceVal}>
            Thực thi Slice
          </button>
        </div>

        {/* Dice Section */}
        <div className="mb-4 p-2 border rounded border-success">
          <h6 className="text-success">🎲 Dice (Đổ ngầu)</h6>
          <small className="text-muted d-block mb-2">Kết hợp nhiều điều kiện cắt (AND).</small>
          
          <div className="input-group input-group-sm mb-2">
            <select className="form-select" style={{maxWidth: '120px'}} value={diceDim1} onChange={(e) => setDiceDim1(e.target.value)} disabled={loading}>
              {dimensions.map(dim => <option key={dim} value={dim}>{dim}</option>)}
            </select>
            <input type="text" className="form-control" placeholder="Giá trị..." value={diceVal1} onChange={e => setDiceVal1(e.target.value)} disabled={loading} />
          </div>
          
          <div className="input-group input-group-sm mb-2">
            <select className="form-select" style={{maxWidth: '120px'}} value={diceDim2} onChange={(e) => setDiceDim2(e.target.value)} disabled={loading}>
              {dimensions.map(dim => <option key={dim} value={dim}>{dim}</option>)}
            </select>
            <input type="text" className="form-control" placeholder="Giá trị..." value={diceVal2} onChange={e => setDiceVal2(e.target.value)} disabled={loading} />
          </div>

          <button className={`btn btn-sm btn-success w-100 ${activeOperation === 'dice' ? 'active' : ''}`} onClick={handleDice} disabled={loading || (!diceVal1 && !diceVal2)}>
            Thực thi Dice
          </button>
        </div>

        {/* Pivot Section */}
        <div className="mb-2 p-2 border rounded bg-light">
          <h6>🔄 Pivot (Xoay trục)</h6>
          <button className={`btn btn-sm btn-secondary w-100 ${activeOperation === 'pivot' ? 'active' : ''}`} onClick={handlePivot} disabled={loading}>
            Thực thi Pivot
          </button>
        </div>

      </div>
    </div>
  );
}

export default OLAPOperations;
