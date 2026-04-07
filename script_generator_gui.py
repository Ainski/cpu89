#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
script_generator_gui.py
使用 PyQt5 开发的 CPU 测试结果查看器
更紧凑、更美观的界面设计
"""

import sys
import os
import subprocess
from pathlib import Path
from PyQt5.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, 
                             QHBoxLayout, QListWidget, QListWidgetItem, QTabWidget,
                             QTextEdit, QLabel, QPushButton, QSplitter, QFrame,
                             QMessageBox, QHeaderView)
from PyQt5.QtCore import Qt, QSize
from PyQt5.QtGui import QFont, QColor, QTextCursor


class TestResultsViewer(QMainWindow):
    """CPU 测试结果查看器主窗口"""
    
    def __init__(self, results_dir, testdata_dir):
        super().__init__()
        self.results_dir = Path(results_dir)
        self.testdata_dir = Path(testdata_dir)
        self.test_cases = []
        self.test_results = {}
        
        self.init_ui()
        self.load_test_cases()
        
    def init_ui(self):
        """初始化界面"""
        self.setWindowTitle("CPU 测试结果查看器")
        self.setGeometry(100, 100, 1400, 900)
        
        # 设置全局字体
        self.setFont(QFont("Microsoft YaHei", 9))
        
        # 创建中央部件
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        
        # 主布局
        main_layout = QVBoxLayout(central_widget)
        main_layout.setContentsMargins(5, 5, 5, 5)
        main_layout.setSpacing(5)
        
        # 创建分割器（左侧列表 + 右侧内容）
        splitter = QSplitter(Qt.Horizontal)
        
        # 左侧：测试用例列表
        left_widget = self.create_left_panel()
        splitter.addWidget(left_widget)
        
        # 右侧：文件内容显示区
        right_widget = self.create_right_panel()
        splitter.addWidget(right_widget)
        
        # 设置分割器比例 (30% : 70%)
        splitter.setStretchFactor(0, 3)
        splitter.setStretchFactor(1, 7)
        splitter.setSizes([400, 1000])
        
        main_layout.addWidget(splitter)
        
        # 底部：统计信息栏
        stats_widget = self.create_stats_panel()
        main_layout.addWidget(stats_widget)
        
        # 应用样式
        self.apply_style()
        
    def create_left_panel(self):
        """创建左侧测试用例列表面板"""
        left_widget = QWidget()
        left_layout = QVBoxLayout(left_widget)
        left_layout.setContentsMargins(0, 0, 0, 0)
        left_layout.setSpacing(2)
        
        # 标题
        title_label = QLabel("测试用例列表")
        title_label.setFont(QFont("Microsoft YaHei", 10, QFont.Bold))
        title_label.setStyleSheet("padding: 5px; background-color: #f0f0f0; border: 1px solid #ccc;")
        left_layout.addWidget(title_label)
        
        # 测试用例列表
        self.test_list = QListWidget()
        self.test_list.setFont(QFont("Consolas", 9))
        self.test_list.currentRowChanged.connect(self.on_test_selected)
        left_layout.addWidget(self.test_list)
        
        return left_widget
    
    def create_right_panel(self):
        """创建右侧内容显示面板"""
        right_widget = QWidget()
        right_layout = QVBoxLayout(right_widget)
        right_layout.setContentsMargins(0, 0, 0, 0)
        right_layout.setSpacing(2)
        
        # 创建标签页
        self.tab_widget = QTabWidget()
        self.tab_widget.setTabPosition(QTabWidget.North)
        self.tab_widget.setStyleSheet("""
            QTabWidget::pane {
                border: 1px solid #ccc;
            }
            QTabBar::tab {
                padding: 5px 15px;
                margin-right: 2px;
            }
            QTabBar::tab:selected {
                background-color: #fff;
                border-bottom-color: #fff;
            }
        """)
        
        # 创建五个标签页
        self.tabs = {}
        tab_names = [
            ('hex', 'HEX 机器码'),
            ('txt', '汇编源码'),
            ('sim_result', '仿真输出'),
            ('std_result', '标准输出'),
            ('comparison_result', '比对结果')
        ]
        
        for tab_id, tab_title in tab_names:
            text_edit = QTextEdit()
            text_edit.setReadOnly(True)
            text_edit.setFont(QFont("Consolas", 9))
            text_edit.setStyleSheet("padding: 5px;")
            self.tab_widget.addTab(text_edit, tab_title)
            self.tabs[tab_id] = text_edit
        
        right_layout.addWidget(self.tab_widget)
        
        return right_widget
    
    def create_stats_panel(self):
        """创建底部统计信息面板"""
        stats_widget = QFrame()
        stats_widget.setStyleSheet("""
            background-color: #f8f8f8;
            border: 1px solid #ccc;
            padding: 8px;
        """)
        
        stats_layout = QHBoxLayout(stats_widget)
        stats_layout.setContentsMargins(10, 5, 10, 5)
        
        # 统计信息标签
        self.stats_label = QLabel()
        self.stats_label.setFont(QFont("Microsoft YaHei", 10, QFont.Bold))
        stats_layout.addWidget(self.stats_label)
        
        stats_layout.addStretch()
        
        # 打开日志按钮
        self.log_button = QPushButton("📄 打开最新仿真日志")
        self.log_button.setFont(QFont("Microsoft YaHei", 9))
        self.log_button.setStyleSheet("""
            QPushButton {
                background-color: #4CAF50;
                color: white;
                padding: 5px 15px;
                border: none;
                border-radius: 3px;
            }
            QPushButton:hover {
                background-color: #45a049;
            }
            QPushButton:pressed {
                background-color: #3d8b40;
            }
        """)
        self.log_button.clicked.connect(self.open_latest_log)
        stats_layout.addWidget(self.log_button)
        
        return stats_widget
    
    def apply_style(self):
        """应用全局样式"""
        self.setStyleSheet("""
            QMainWindow {
                background-color: #ffffff;
            }
            QListWidget {
                border: 1px solid #ccc;
                border-radius: 3px;
                padding: 2px;
            }
            QListWidget::item {
                padding: 5px;
                border-bottom: 1px solid #f0f0f0;
            }
            QListWidget::item:selected {
                background-color: #e3f2fd;
                color: #000;
            }
            QListWidget::item:hover {
                background-color: #f5f5f5;
            }
            QTextEdit {
                border: 1px solid #ccc;
                border-radius: 3px;
            }
        """)
    
    def load_test_cases(self):
        """加载所有测试用例"""
        testdata_path = self.testdata_dir
        results_path = self.results_dir
        
        # 获取所有 hex.txt 文件
        hex_files = sorted(testdata_path.glob('*.hex.txt'))
        
        if not hex_files:
            QMessageBox.warning(self, "警告", f"在 {testdata_path} 中未找到测试文件")
            return
        
        # 加载测试用例
        for hex_file in hex_files:
            test_name = hex_file.stem.replace('.hex', '')
            
            test_case = {
                'name': test_name,
                'hex_file': hex_file,
                'txt_file': hex_file.with_suffix('').with_suffix('').with_suffix(".txt"),
                'sim_result': results_path / f'{test_name}_sim_result.txt',
                'std_result': results_path / f'{test_name}_std_result.txt',
                'comparison_result': results_path / f'{test_name}_comparison_result.txt'
            }
            self.test_cases.append(test_case)
            
            # 检查测试结果
            sim_result = test_case['sim_result']
            std_result = test_case['std_result']
            
            if sim_result.exists() and std_result.exists():
                try:
                    with open(sim_result, 'r', encoding='cp936') as f:
                        sim_content = f.read()
                    with open(std_result, 'r', encoding='utf-8') as f:
                        std_content = f.read()
                    if sim_content.strip() == std_content.strip():
                        self.test_results[test_name] = 'pass'
                    else:
                        self.test_results[test_name] = 'fail'
                except:
                    self.test_results[test_name] = 'fail'
            else:
                self.test_results[test_name] = 'unknown'
            
            # 添加到列表
            item = QListWidgetItem(test_name)
            item.setData(Qt.UserRole, test_case)
            self.test_list.addItem(item)
        
        # 设置颜色
        self.update_list_colors()
        
        # 更新统计信息
        self.update_stats()
        
        # 默认选中第一个
        if self.test_cases:
            self.test_list.setCurrentRow(0)
    
    def update_list_colors(self):
        """更新列表项颜色"""
        for idx in range(self.test_list.count()):
            item = self.test_list.item(idx)
            test_name = item.text()
            result = self.test_results.get(test_name, 'unknown')
            
            if result == 'pass':
                item.setForeground(QColor("#2e7d32"))  # 绿色
            elif result == 'fail':
                item.setForeground(QColor("#c62828"))  # 红色
            else:
                item.setForeground(QColor("#9e9e9e"))  # 灰色
    
    def update_stats(self):
        """更新统计信息"""
        pass_count = sum(1 for r in self.test_results.values() if r == 'pass')
        fail_count = sum(1 for r in self.test_results.values() if r == 'fail')
        total = len(self.test_cases)
        
        if total > 0:
            rate = pass_count / total * 100
            stats_text = f"总计: {total} 个测试  |  通过: {pass_count}  |  失败: {fail_count}  |  通过率: {rate:.1f}%"
        else:
            stats_text = "无测试用例"
        
        self.stats_label.setText(stats_text)
    
    def on_test_selected(self, row):
        """测试用例选中事件"""
        if row < 0 or row >= len(self.test_cases):
            return
        
        test_case = self.test_cases[row]
        
        # 清空所有内容
        for text_edit in self.tabs.values():
            text_edit.clear()
        
        # 读取并显示 hex 文件
        self.load_file_content(self.tabs['hex'], test_case['hex_file'], 'utf-8')
        
        # 读取并显示 txt 文件 (汇编源码)
        self.load_file_content(self.tabs['txt'], test_case['txt_file'], 'utf-8')
        
        # 读取并显示仿真结果
        self.load_file_content(self.tabs['sim_result'], test_case['sim_result'], 'cp936')
        
        # 读取并显示标准结果
        self.load_file_content(self.tabs['std_result'], test_case['std_result'], 'utf-8')
        
        # 读取并显示比对结果
        self.load_file_content(self.tabs['comparison_result'], test_case['comparison_result'], 'cp936')
    
    def load_file_content(self, text_edit, file_path, encoding='utf-8'):
        """加载文件内容到文本框"""
        try:
            if file_path.exists():
                with open(file_path, 'r', encoding=encoding) as f:
                    content = f.read()
                text_edit.setPlainText(content)
                # 滚动到顶部
                cursor = text_edit.textCursor()
                cursor.setPosition(0)
                text_edit.setTextCursor(cursor)
            else:
                text_edit.setPlainText(f'文件不存在: {file_path}')
        except Exception as e:
            text_edit.setPlainText(f'读取失败: {e}')
    
    def open_latest_log(self):
        """打开最新的仿真日志文件"""
        log_dir = Path("log")
        if not log_dir.exists():
            QMessageBox.warning(self, "警告", "日志目录不存在")
            return
        
        # 获取所有 .log 文件
        log_files = sorted(log_dir.glob("*.log"), key=os.path.getmtime, reverse=True)
        if not log_files:
            QMessageBox.warning(self, "警告", "未找到日志文件")
            return
        
        # 打开最新的日志文件
        latest_log = log_files[0]
        try:
            if sys.platform.startswith('win'):
                os.startfile(str(latest_log))
            elif sys.platform == 'darwin':
                subprocess.Popen(['open', str(latest_log)])
            else:
                subprocess.Popen(['xdg-open', str(latest_log)])
        except Exception as e:
            QMessageBox.critical(self, "错误", f"无法打开日志文件: {e}")


def show_gui_results(results_dir, testdata_dir):
    """显示 GUI 结果查看器"""
    app = QApplication(sys.argv)
    
    # 设置应用样式
    app.setStyle('Fusion')
    
    viewer = TestResultsViewer(results_dir, testdata_dir)
    viewer.show()
    
    sys.exit(app.exec_())


if __name__ == '__main__':
    # 测试用
    import argparse
    
    parser = argparse.ArgumentParser(description="CPU 测试结果查看器 (PyQt5)")
    parser.add_argument("--results-dir", default="./test_scripts/results", help="结果目录路径")
    parser.add_argument("--testdata-dir", default="./test_scripts/testdata", help="测试数据目录路径")
    args = parser.parse_args()
    
    show_gui_results(args.results_dir, args.testdata_dir)
