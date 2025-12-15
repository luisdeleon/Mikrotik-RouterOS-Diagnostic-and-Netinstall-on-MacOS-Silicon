"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SshClient = void 0;
var ssh2_1 = require("ssh2");
/**
 * SSH Client wrapper for RouterOS
 */
var SshClient = /** @class */ (function () {
    function SshClient(config) {
        this.client = new ssh2_1.Client();
        this.config = config;
    }
    /**
     * Connect to the RouterOS device
     */
    SshClient.prototype.connect = function () {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                return [2 /*return*/, new Promise(function (resolve, reject) {
                        var connectConfig = {
                            host: _this.config.host,
                            port: _this.config.port,
                            username: _this.config.username,
                            password: _this.config.password,
                            readyTimeout: 10000,
                            keepaliveInterval: 5000,
                        };
                        _this.client
                            .on('ready', function () {
                            resolve();
                        })
                            .on('error', function (err) {
                            reject(err);
                        })
                            .connect(connectConfig);
                    })];
            });
        });
    };
    /**
     * Execute a command on the RouterOS device
     */
    SshClient.prototype.executeCommand = function (command) {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                return [2 /*return*/, new Promise(function (resolve, reject) {
                        _this.client.exec(command, function (err, stream) {
                            if (err) {
                                reject(err);
                                return;
                            }
                            var output = '';
                            var errorOutput = '';
                            stream
                                .on('close', function () {
                                if (errorOutput) {
                                    reject(new Error(errorOutput));
                                }
                                else {
                                    resolve(output);
                                }
                            })
                                .on('data', function (data) {
                                output += data.toString();
                            })
                                .stderr.on('data', function (data) {
                                errorOutput += data.toString();
                            });
                        });
                    })];
            });
        });
    };
    /**
     * Execute multiple commands sequentially
     */
    SshClient.prototype.executeCommands = function (commands) {
        return __awaiter(this, void 0, void 0, function () {
            var results, _i, commands_1, command, output, error_1;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        results = new Map();
                        _i = 0, commands_1 = commands;
                        _a.label = 1;
                    case 1:
                        if (!(_i < commands_1.length)) return [3 /*break*/, 6];
                        command = commands_1[_i];
                        _a.label = 2;
                    case 2:
                        _a.trys.push([2, 4, , 5]);
                        return [4 /*yield*/, this.executeCommand(command)];
                    case 3:
                        output = _a.sent();
                        results.set(command, output);
                        return [3 /*break*/, 5];
                    case 4:
                        error_1 = _a.sent();
                        results.set(command, "Error: ".concat(error_1));
                        return [3 /*break*/, 5];
                    case 5:
                        _i++;
                        return [3 /*break*/, 1];
                    case 6: return [2 /*return*/, results];
                }
            });
        });
    };
    /**
     * Disconnect from the RouterOS device
     */
    SshClient.prototype.disconnect = function () {
        this.client.end();
    };
    /**
     * Test connection to the RouterOS device
     */
    SshClient.prototype.testConnection = function () {
        return __awaiter(this, void 0, void 0, function () {
            var error_2;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 3, , 4]);
                        return [4 /*yield*/, this.connect()];
                    case 1:
                        _a.sent();
                        return [4 /*yield*/, this.executeCommand('/system identity print')];
                    case 2:
                        _a.sent();
                        this.disconnect();
                        return [2 /*return*/, true];
                    case 3:
                        error_2 = _a.sent();
                        return [2 /*return*/, false];
                    case 4: return [2 /*return*/];
                }
            });
        });
    };
    return SshClient;
}());
exports.SshClient = SshClient;
