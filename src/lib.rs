use zed_extension_api::{self as zed, Command, LanguageServerId, Result, Worktree};

struct PostgresToolsExtension;

impl zed::Extension for PostgresToolsExtension {
    fn new() -> Self {
        Self
    }

    fn language_server_command(
        &mut self,
        _: &LanguageServerId,
        worktree: &Worktree,
    ) -> Result<Command> {
        let command = worktree
            .which("postgrestools")
            .ok_or_else(|| "postgrestools must be installed manually".to_string())?;

        Ok(Command {
            command,
            args: vec!["lsp-proxy".into()],
            env: worktree.shell_env(),
        })
    }
}

zed::register_extension!(PostgresToolsExtension);
