#!/bin/bash
set -e

# Удаляем всю папку ASOFlow (Клоаку, Роутер, WebKit)
rm -rf OpenStudioPress/Features/ASOFlow
rm -rf OpenStudioPressTests/ASOFlow
rm -f OpenStudioPress/Kernel/AnalyticsDependency.swift
rm -f OpenStudioPress/GoogleService-Info.plist

echo "Папка ASOFlow удалена"
