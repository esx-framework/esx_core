import React from 'react';

const WeightBar: React.FC<{ percent: number; durability?: boolean }> = ({
  percent,
  durability,
}) => {

  return (
    <div className={durability ? 'item-durability' : 'weight-bar'}>
      <div
        style={{
          visibility: percent > 0 ? 'visible' : 'hidden',
          width: `${percent}%`,
          backgroundColor: "#00e7ff",
          transition: `background ${0.3}s ease, width ${0.3}s ease`,
        }}
      ></div>
    </div>
  );
};
export default WeightBar;
