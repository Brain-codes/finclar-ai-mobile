import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

// Single source of truth for all icons used in the app.
// Never use Remix or any icon set directly — always go through AppIcons.
// To swap icon sets later, only this file needs to change.
abstract class AppIcons {
  // Navigation
  static const IconData home = Remix.home_4_line;
  static const IconData homeActive = Remix.home_4_fill;
  static const IconData expenses = Remix.exchange_dollar_line;
  static const IconData expensesActive = Remix.exchange_dollar_fill;
  static const IconData budget = Remix.pie_chart_line;
  static const IconData budgetActive = Remix.pie_chart_fill;
  static const IconData group = Remix.team_line;
  static const IconData groupActive = Remix.team_fill;
  static const IconData add = Remix.add_circle_line;

  // Auth
  static const IconData email = Remix.mail_line;
  static const IconData phone = Remix.phone_line;
  static const IconData lock = Remix.lock_line;
  static const IconData eyeOn = Remix.eye_line;
  static const IconData eyeOff = Remix.eye_off_line;
  static const IconData user = Remix.user_line;
  static const IconData userFill = Remix.user_fill;

  // Actions
  static const IconData back = Remix.arrow_left_line;
  static const IconData forward = Remix.arrow_right_line;
  static const IconData close = Remix.close_line;
  static const IconData check = Remix.check_line;
  static const IconData edit = Remix.edit_line;
  static const IconData delete = Remix.delete_bin_line;
  static const IconData more = Remix.more_2_line;
  static const IconData search = Remix.search_line;
  static const IconData filter = Remix.filter_line;
  static const IconData notification = Remix.notification_3_line;
  static const IconData settings = Remix.settings_3_line;
  static const IconData share = Remix.share_line;
  static const IconData copy = Remix.file_copy_line;
  static const IconData scan = Remix.scan_line;
  static const IconData camera = Remix.camera_line;
  static const IconData attachment = Remix.attachment_line;

  // Finance
  static const IconData wallet = Remix.wallet_3_line;
  static const IconData walletFill = Remix.wallet_3_fill;
  static const IconData income = Remix.arrow_down_circle_line;
  static const IconData expense = Remix.arrow_up_circle_line;
  static const IconData transfer = Remix.exchange_line;
  static const IconData bank = Remix.bank_line;
  static const IconData card = Remix.bank_card_line;
  static const IconData chart = Remix.line_chart_line;
  static const IconData chartFill = Remix.line_chart_fill;

  // AI / Chat
  static const IconData ai = Remix.sparkling_2_line;
  static const IconData aiFill = Remix.sparkling_2_fill;
  static const IconData send = Remix.send_plane_line;
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
  static const IconData location = Remix.map_pin_line;
  static const IconData link = Remix.link;
  static const IconData logout = Remix.logout_box_r_line;
  // static const IconData crown = Remix.crown_line;
  // static const IconData crownFill = Remix.crown_fill;
  static const IconData chevronRight = Remix.arrow_right_s_line;
  static const IconData chevronDown = Remix.arrow_down_s_line;
  static const IconData chevronUp = Remix.arrow_up_s_line;
}
