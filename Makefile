install:
	./install.sh

install-claude:
	@bash scripts/install-claude.sh

uninstall-claude:
	@bash scripts/uninstall-claude.sh

status:
	@bash scripts/status-claude.sh

help:
	@echo "Targets:"
	@echo "  install            dotfiles 全体をインストール"
	@echo "  install-claude     Claude 設定のみ（symlink 作成）"
	@echo "  uninstall-claude   Claude symlink を解除・復元"
	@echo "  status             symlink 状態を確認"
	@echo "  help               このヘルプ"
	@echo ""
	@echo "Options:"
	@echo "  DRY_RUN=1          変更を行わず予定操作を表示"
	@echo "  VERBOSE=1          詳細ログを表示"

.PHONY: install install-claude uninstall-claude status help
