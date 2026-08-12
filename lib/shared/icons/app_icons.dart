import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

// Single source of truth for all icons used in the app.
// Never use Remix or any icon set directly — always go through AppIcons.
// To swap icon sets later, only this file needs to change.
abstract class AppIcons {
  // Navigation
  static const IconData home = Remix.home_6_line;
  static const IconData homeActive = Remix.home_6_fill;
  static const IconData expenses = Remix.file_list_3_line;
  static const IconData expensesActive = Remix.file_list_3_fill;
  static const IconData budget = Remix.pie_chart_line;
  static const IconData budgetActive = Remix.pie_chart_fill;
  static const IconData group = Remix.group_line;
  static const IconData groupActive = Remix.group_fill;
  static const IconData add = Remix.add_large_line;
  static const IconData addUser = Remix.user_add_line;

  // Auth
  static const IconData email = Remix.mail_line;
  static const IconData phone = Remix.phone_line;
  static const IconData lock = Remix.lock_line;
  static const IconData eyeOn = Remix.eye_line;
  static const IconData eyeOff = Remix.eye_off_line;
  static const IconData user = Remix.user_line;
  static const IconData userFill = Remix.user_fill;
  static const IconData fingerprint = Remix.fingerprint_line;

  // Actions
  static const IconData back = Remix.arrow_left_s_line;
  static const IconData forward = Remix.arrow_right_s_line;
  static const IconData close = Remix.close_line;
  static const IconData check = Remix.check_line;
  static const IconData edit = Remix.edit_line;
  static const IconData editFill = Remix.edit_fill;
  static const IconData delete = Remix.delete_bin_line;
  static const IconData more = Remix.more_2_line;
  static const IconData search = Remix.search_line;
  static const IconData filter = Remix.filter_line;
  static const IconData notification = Remix.notification_3_line;
  static const IconData notificationActive = Remix.notification_3_fill;
  static const IconData settings = Remix.settings_3_line;
  static const IconData volumeUp = Remix.volume_up_line;
  static const IconData volumeMute = Remix.volume_mute_line;
  static const IconData share = Remix.share_line;
  static const IconData copy = Remix.file_copy_line;
  static const IconData scan = Remix.scan_line;
  static const IconData camera = Remix.camera_line;
  static const IconData cameraFill = Remix.camera_fill;
  static const IconData attachment = Remix.attachment_line;
  static const IconData download = Remix.download_line;

  // Finance
  static const IconData wallet = Remix.wallet_fill;
  static const IconData walletFill = Remix.wallet_fill;
  static const IconData walletLine = Remix.wallet_line;
  static const IconData file = Remix.file_line;
  static const IconData income = Remix.arrow_down_circle_line;
  static const IconData expense = Remix.arrow_up_circle_line;
  static const IconData transfer = Remix.exchange_line;
  static const IconData bank = Remix.bank_line;
  static const IconData card = Remix.bank_card_line;
  static const IconData chart = Remix.bar_chart_fill;
  static const IconData chartFill = Remix.bar_chart_fill;

  // AI / Chat
  static const IconData ai = Remix.sparkling_2_line;
  static const IconData briefcase = Remix.briefcase_4_fill;
  static const IconData aiFill = Remix.sparkling_2_fill;
  static const IconData send = Remix.send_plane_line;
  static const IconData send2 = Remix.send_plane_fill;
  static const IconData chat = Remix.chat_3_line;
  static const IconData chatFill = Remix.chat_3_fill;
  static const IconData mic = Remix.mic_line;
  static const IconData micOff = Remix.mic_off_line;

  // Status
  static const IconData success = Remix.checkbox_circle_line;
  static const IconData error = Remix.error_warning_line;
  static const IconData warning = Remix.alert_line;
  static const IconData info = Remix.information_line;

  // Misc
  static const IconData calendar = Remix.calendar_line;
  static const IconData clock = Remix.time_line;
  static const IconData refresh = Remix.refresh_line;
  static const IconData location = Remix.map_pin_line;
  static const IconData link = Remix.link;
  static const IconData logout = Remix.logout_box_r_line;
  // static const IconData crown = Remix.crown_line;
  // static const IconData crownFill = Remix.crown_fill;
  static const IconData chevronRight = Remix.arrow_right_s_line;
  static const IconData chevronDown = Remix.arrow_down_s_line;
  static const IconData chevronUp = Remix.arrow_up_s_line;

  // Selection
  static const IconData radioChecked = Remix.radio_button_fill;
  static const IconData radioUnchecked = Remix.radio_button_line;
  static const IconData circle = Remix.circle_line;
  static const IconData addCircle = Remix.add_circle_line;
  static const IconData flag = Remix.flag_line;
  static const IconData target = Remix.focus_line;

  // Settings
  static const IconData theme = Remix.contrast_2_line;
  static const IconData themeLight = Remix.sun_line;
  static const IconData themeDark = Remix.moon_line;
  static const IconData themeSystem = Remix.smartphone_line;
  static const IconData crown = Remix.vip_crown_line;
  static const IconData shield = Remix.shield_check_line;
  static const IconData star = Remix.star_line;
  static const IconData medal = Remix.medal_line;
  static const IconData passport = Remix.passport_line;
  static const IconData headphone = Remix.customer_service_2_line;
  static const IconData question = Remix.question_line;
  static const IconData instagram = Remix.instagram_line;
  static const IconData twitter = Remix.twitter_x_line;
  static const IconData linkedin = Remix.linkedin_box_line;
  static const IconData youtube = Remix.youtube_fill;
  static const IconData image = Remix.image_line;
  static const IconData whatsapp = Remix.whatsapp_line;

  // Expense categories
  static const IconData categoryFood = Remix.restaurant_line;
  static const IconData categoryTransport = Remix.car_line;
  static const IconData categoryHealth = Remix.heart_pulse_line;
  static const IconData categoryShopping = Remix.shopping_bag_line;
  static const IconData categoryEntertainment = Remix.movie_line;
  static const IconData categoryBills = Remix.flashlight_line;
  static const IconData categoryTravel = Remix.plane_line;
  static const IconData categoryOther = Remix.more_2_line;
  static const IconData categoryUtilities = Remix.flashlight_line;
  static const IconData categoryEducation = Remix.book_line;
  static const IconData categoryInvestment = Remix.line_chart_line;
  static const IconData categorySavings = Remix.safe_2_line;
  static const IconData categoryRent = Remix.home_line;
  static const IconData categoryGrid = Remix.grid_line;

  // Gamification
  static const IconData flame   = Remix.fire_line;
  static const IconData trophy  = Remix.trophy_line;
  static const IconData game    = Remix.gamepad_line;
  static const IconData sparkle = Remix.sparkling_line;

  // GROUP
  static const IconData message = Remix.discuss_line;
  // static const IconData link = Remix.link;
}
