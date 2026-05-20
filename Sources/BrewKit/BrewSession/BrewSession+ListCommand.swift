import Foundation

// MARK: - brew list

extension BrewSession {
    /// Returns installed formulae with version and install reason.
    /// 返回已安装 formula 的版本与安装原因。
    /// - Returns: Installed formula package list.
    /// - 返回值: 已安装 formula 软件包列表。
    public func installedFormulae() async throws(BrewSessionError) -> [BrewInstalledPackage] {
        let listResult = try await runCommand(args: ["list", "--formula", "--versions"])
        var packages = Self.parseInstalledFormulaeList(listResult.stdout)

        let infoResult = try await runCommand(args: [
            "info", "--json=v2", "--formula", "--installed",
        ])
        let reasonMap = try Self.parseInstallReasons(
            infoResult.stdout,
            command: commandString(args: ["info", "--json=v2", "--formula", "--installed"]))

        packages = packages.map { pkg in
            BrewInstalledPackage(
                name: pkg.name,
                version: pkg.version,
                kind: pkg.kind,
                installReason: reasonMap[pkg.name] ?? .unknown
            )
        }

        return packages
    }

    /// Returns installed casks with versions.
    /// 返回已安装 cask 及其版本。
    /// - Returns: Installed cask package list.
    /// - 返回值: 已安装 cask 软件包列表。
    public func installedCasks() async throws(BrewSessionError) -> [BrewInstalledPackage] {
        let listResult = try await runCommand(args: ["list", "--cask"])
        let names = Self.parseLineValues(listResult.stdout)
        if names.isEmpty { return [] }

        let args = ["info", "--cask", "--json=v2"] + names
        let infoResult = try await runCommand(args: args)
        let versionMap = try Self.parseCaskVersions(
            infoResult.stdout, command: commandString(args: args))

        return names.map {
            BrewInstalledPackage(
                name: $0, version: versionMap[$0] ?? "Unknown", kind: .cask, installReason: nil)
        }
    }
}
