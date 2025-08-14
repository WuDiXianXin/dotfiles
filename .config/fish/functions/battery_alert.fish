#!/usr/bin/fish

# 电池电量监控脚本：支持低电量提醒和充电至90%提醒
# 依赖：acpi, libnotify, pw-play/paplay
# 配置参数可根据需求调整

# 配置参数
set LOW_BATTERY_THRESHOLD 20 # 低电量阈值(百分比)
set CRITICAL_THRESHOLD 10 # 严重低电量阈值(百分比)
set HIGH_CHARGE_THRESHOLD 90 # 高电量充电提醒阈值(百分比)
set CHECK_INTERVAL 300 # 检查间隔(秒)
set ALERT_SOUND "/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga" # 提示音路径

# 检查音频播放工具是否可用
if command -v pw-play &>/dev/null
    set PLAY_CMD pw-play
else if command -v paplay &>/dev/null
    set PLAY_CMD paplay
else
    echo "错误: 未找到音频播放工具 (pw-play 或 paplay)"
    exit 1
end

# 检查acpi是否可用
if not command -v acpi &>/dev/null
    echo "错误: 未找到acpi命令，请安装acpi工具"
    exit 1
end

# 用于跟踪是否已发送过高电量提醒，避免重复提醒
set high_alert_sent 0

while true
    # 获取电池状态信息
    set BATTERY_INFO (acpi -b)
    set BATTERY_LEVEL (echo $BATTERY_INFO | grep -P -o '[0-9]+(?=%)')
    set STATUS (echo $BATTERY_INFO | grep -oE 'Charging|Discharging|Full')

    # 检查电池信息是否有效
    if test -z "$BATTERY_LEVEL" -o -z "$STATUS"
        echo "警告: 无法解析电池信息，跳过本次检查"
        sleep $CHECK_INTERVAL
        continue
    end

    # 充电状态下检查高电量
    if test "$STATUS" = Charging
        # 当电量达到或超过90%且尚未发送提醒时
        if test $BATTERY_LEVEL -ge $HIGH_CHARGE_THRESHOLD && test $high_alert_sent -eq 0
            notify-send -u low 充电提醒 "当前电量: $BATTERY_LEVEL%，建议断开充电器"
            $PLAY_CMD $ALERT_SOUND
            set high_alert_sent 1 # 标记已发送提醒
            sleep $CHECK_INTERVAL
            continue
        end
    else
        # 非充电状态时重置高电量提醒标记（修复了语法错误）
        set high_alert_sent 0
    end

    # 放电状态下检查低电量
    if test "$STATUS" = Discharging
        # 低电量提示
        if test $BATTERY_LEVEL -le $LOW_BATTERY_THRESHOLD && test $BATTERY_LEVEL -gt $CRITICAL_THRESHOLD
            notify-send -u normal 电量不足 "当前电量: $BATTERY_LEVEL%，请尽快充电"
            $PLAY_CMD $ALERT_SOUND
            sleep $CHECK_INTERVAL
            continue
        end

        # 严重低电量提示
        if test $BATTERY_LEVEL -le $CRITICAL_THRESHOLD
            notify-send -u critical 电量严重不足 "当前电量: $BATTERY_LEVEL%，即将关闭"
            $PLAY_CMD $ALERT_SOUND
            sleep $CHECK_INTERVAL
            continue
        end
    end

    # 电池充满时的提醒（新增）
    if test "$STATUS" = Full
        notify-send -u low 电池已充满 "当前电量: 100%，请断开充电器"
        $PLAY_CMD $ALERT_SOUND
        set high_alert_sent 1 # 标记已发送提醒
        sleep $CHECK_INTERVAL
        continue
    end

    sleep $CHECK_INTERVAL
end
