/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports) {

let isNuiActive = false;

function NuiMessage(msg) {
  window.SendNuiMessage(JSON.stringify(msg));
}

function NuiCallback(name, callback) {
  window.RegisterNuiCallbackType(name);
  window.on(`__cfx_nui:${name}`, (data, cb) => {
    callback(data);
    cb('ok');
  });
}

function setNuiActive(boolean = true) {
  if (boolean !== isNuiActive) {
    if (boolean) {
      window.emitNet('mysql-async:request-data');
    }
    isNuiActive = boolean;
    NuiMessage({ type: 'onToggleShow' });
    window.SetNuiFocus(boolean, boolean);
  }
}

window.RegisterCommand('mysql', () => {
  setNuiActive();
}, true);

NuiCallback('close-explorer', () => {
  setNuiActive(false);
});

window.setInterval(() => {
  if (isNuiActive) {
    window.emitNet('mysql-async:request-data');
  }
}, 300000);

window.onNet('mysql-async:update-resource-data', (resourceData) => {
  let arrayToSortAndMap = [];
  const resources = Object.keys(resourceData);
  for (let i = 0; i < resources.length; i += 1) {
    if (Object.prototype.hasOwnProperty.call(resourceData, resources[i])) {
      if (Object.prototype.hasOwnProperty.call(resourceData[resources[i]], 'totalExecutionTime')) {
        arrayToSortAndMap.push({
          resource: resources[i],
          queryTime: resourceData[resources[i]].totalExecutionTime,
          count: resourceData[resources[i]].queryCount,
        });
      }
    }
  }
  if (arrayToSortAndMap.length > 0) {
    arrayToSortAndMap.sort((a, b) => a.queryTime - b.queryTime);
    const len = arrayToSortAndMap.length;
    arrayToSortAndMap = arrayToSortAndMap.filter((_, index) => index > len - 31);
    arrayToSortAndMap.sort((a, b) => {
      const resourceA = a.resource.toLowerCase();
      const resourceB = b.resource.toLowerCase();
      let result = 0;
      if (resourceA < resourceB) {
        result = -1;
      } else if (resourceA > resourceB) {
        result = 1;
      }
      return result;
    });
    NuiMessage({
      type: 'onResourceLabels',
      resourceLabels: arrayToSortAndMap.map(el => el.resource),
    });
    NuiMessage({
      type: 'onResourceData',
      resourceData: [
        {
          data: arrayToSortAndMap.map(el => el.queryTime),
        },
        {
          data: arrayToSortAndMap.map(el => ((el.count > 0) ? el.queryTime / el.count : 0)),
        },
        {
          data: arrayToSortAndMap.map(el => el.count),
        },
      ],
    });
  }
});

window.onNet('mysql-async:update-time-data', (timeData) => {
  let timeArray = [];
  if (Array.isArray(timeData)) {
    const len = timeData.length;
    timeArray = timeData.filter((_, index) => index > len - 31);
  }
  if (timeArray.length > 0) {
    NuiMessage({
      type: 'onTimeData',
      timeData: [
        {
          data: timeArray.map(el => el.totalExecutionTime),
        },
        {
          data: timeArray.map(el => ((el.queryCount > 0) ? el.totalExecutionTime / el.queryCount
            : 0)),
        },
        {
          data: timeArray.map(el => el.queryCount),
        },
      ],
    });
  }
});

window.onNet('mysql-async:update-slow-queries', (slowQueryData) => {
  const slowQueries = slowQueryData.map((el) => {
    const element = el;
    element.queryTime = Math.round(el.queryTime * 100) / 100;
    return element;
  });
  NuiMessage({
    type: 'onSlowQueryData',
    slowQueries,
  });
});


/***/ })
/******/ ]);