# Language: zh-TW
# DSL Layer (L1): Business Domain Language
#
# 這個檔案屬於 DSL 層 (Domain-Specific Language)
# 用途: 描述業務需求和場景,供產品經理、業務分析師閱讀
# 注意: 此檔案不會執行測試,實際測試請參考 ISA 層 (features/isa/)

Feature: 使用者註冊
  作為一個新訪客
  我想要使用帳號和密碼註冊系統
  以便建立屬於自己的帳號

  Scenario: 使用有效的帳號和密碼成功註冊
    When "Alice" 使用密碼 "Test1234!" 進行註冊
    Then 註冊應該成功
    And 系統中應該存在用戶 "Alice"

  Scenario: 嘗試註冊已存在的帳號
    Given 系統中存在一位用戶 "Bob" 密碼為 "Secure123!"
    When "Bob" 使用密碼 "NewPassword456!" 進行註冊
    Then 註冊應該失敗
    And 系統應該提示 "使用者名稱已存在"

  Scenario: 使用最短帳號長度註冊 (3 字元)
    When "Tom" 使用密碼 "Valid123!" 進行註冊
    Then 註冊應該成功
    And 系統中應該存在用戶 "Tom"

  Scenario: 使用最長帳號長度註冊 (50 字元)
    When "user_with_a_very_long_username_for_template_test_5" 使用密碼 "Strong123!" 進行註冊
    Then 註冊應該成功
    And 系統中應該存在用戶 "user_with_a_very_long_username_for_template_test_5"

  Scenario: 使用最短密碼長度註冊 (8 字元)
    When "Charlie" 使用密碼 "Pass123!" 進行註冊
    Then 註冊應該成功
    And 系統中應該存在用戶 "Charlie"

  Scenario: 使用最長密碼長度註冊 (72 字元)
    When "Diana" 使用密碼 "A1!bcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@$%*" 進行註冊
    Then 註冊應該成功
    And 系統中應該存在用戶 "Diana"

  Scenario: 使用過短的帳號註冊失敗 (2 字元)
    When "Ed" 使用密碼 "Valid123!" 進行註冊
    Then 註冊應該失敗
    And 系統應該提示 "使用者名稱或密碼格式無效"

  Scenario: 使用過長的帳號註冊失敗 (51 字元)
    When "user_with_a_very_long_username_for_template_tests51" 使用密碼 "Valid123!" 進行註冊
    Then 註冊應該失敗
    And 系統應該提示 "使用者名稱或密碼格式無效"

  Scenario: 使用包含特殊符號的帳號註冊失敗
    When "alice@chen" 使用密碼 "Valid123!" 進行註冊
    Then 註冊應該失敗
    And 系統應該提示 "使用者名稱或密碼格式無效"

  Scenario: 使用過短的密碼註冊失敗 (7 字元)
    When "Grace" 使用密碼 "Pass12!" 進行註冊
    Then 註冊應該失敗
    And 系統應該提示 "使用者名稱或密碼格式無效"

  Scenario: 使用過長的密碼註冊失敗 (73 字元)
    When "Henry" 使用密碼 "A1!bcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@$%*?" 進行註冊
    Then 註冊應該失敗
    And 系統應該提示 "使用者名稱或密碼格式無效"
