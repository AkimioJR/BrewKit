import Testing

@testable import BrewKit

@Test func outdatedParsingSkipsPinnedFormulaAndKeepsCasks() throws {
    let text = """
        Warning: cask.jws.json: update failed, falling back to cached version.
        {
          "formulae": [
            {
              "name": "abseil",
              "installed_versions": ["20260107.0"],
              "current_version": "20260107.1",
              "pinned": false,
              "pinned_version": null
            },
            {
              "name": "pinned-formula",
              "installed_versions": ["1.0.0"],
              "current_version": "1.1.0",
              "pinned": true,
              "pinned_version": "1.0.0"
            }
          ],
          "casks": [
            {
              "name": "airbattery",
              "installed_versions": ["1.6.0"],
              "current_version": "1.6.2"
            }
          ]
        }
        """

    let packages = try BrewSession.parseOutdated(text, command: "brew outdated --json=v2")

    #expect(packages.count == 2)
    #expect(packages.contains(where: { $0.name == "abseil" && $0.kind == .formula }))
    #expect(packages.contains(where: { $0.name == "airbattery" && $0.kind == .cask }))
    #expect(packages.contains(where: { $0.name == "pinned-formula" }) == false)
}

@Test func infoParsingReturnsStrongTypedModel() throws {
    let text = """
        {
          "formulae": [],
          "casks": [
            {
              "token": "airbattery",
              "full_token": "lihaoyun6/tap/airbattery",
              "desc": "Get the battery level",
              "homepage": "https://github.com/lihaoyun6/AirBattery",
              "version": "1.6.2",
              "installed": "1.6.0",
              "depends_on": {
                "cask": ["foo-helper"],
                "macos": {
                  ">=": ["13"]
                }
              },
              "conflicts_with": {
                "cask": ["foo"]
              },
              "artifacts": [
                { "app": ["AirBattery.app"] }
              ],
              "variations": {
                "sonoma": {
                  "url": "https://example.com/airbattery-sonoma.dmg",
                  "sha256": "abc"
                }
              }
            }
          ]
        }
        """

    let summary = try BrewSession.parseInfo(text, command: "brew info --json=v2 airbattery")

    #expect(summary.name == "airbattery")
    #expect(summary.kind == .cask)
    #expect(summary.version == "1.6.2")
    #expect(summary.fullName == "lihaoyun6/tap/airbattery")
    #expect(summary.installedVersions == ["1.6.0"])
    #expect(summary.caskInfo?.dependsOn?.cask == ["foo-helper"])
    #expect(summary.caskInfo?.conflictsWith?.cask == ["foo"])
    #expect(summary.caskInfo?.variations?.keys.contains("sonoma") == true)
    #expect(summary.formulaInfo == nil)
}

@Test func infoParsingReturnsStructuredFormulaDetails() throws {
    let text = """
        {
          "formulae": [
            {
              "name": "wget",
              "full_name": "homebrew/core/wget",
              "desc": "Internet file retriever",
              "homepage": "https://www.gnu.org/software/wget/",
              "license": "GPL-3.0-or-later",
              "versions": {
                "stable": "1.25.0",
                "head": "HEAD",
                "bottle": true
              },
              "urls": {
                "stable": {
                  "url": "https://example.com/wget.tar.gz",
                  "checksum": "deadbeef"
                }
              },
              "bottle": {
                "stable": {
                  "rebuild": 1,
                  "root_url": "https://ghcr.io/v2/homebrew/core",
                  "files": {
                    "arm64_sonoma": {
                      "cellar": "/opt/homebrew/Cellar",
                      "url": "https://example.com/wget-bottle",
                      "sha256": "bead"
                    }
                  }
                }
              },
              "installed": [
                { "version": "1.24.5" }
              ],
              "variations": {
                "x86_64_linux": {
                  "dependencies": ["openssl@3"]
                }
              }
            }
          ],
          "casks": []
        }
        """

    let summary = try BrewSession.parseInfo(text, command: "brew info --json=v2 wget")

    #expect(summary.kind == .formula)
    #expect(summary.name == "wget")
    #expect(summary.version == "1.25.0")
    #expect(summary.installedVersions == ["1.24.5"])
    #expect(summary.formulaInfo?.bottle?.stable?.files?["arm64_sonoma"]?.sha256 == "bead")
    #expect(summary.formulaInfo?.variations?.keys.contains("x86_64_linux") == true)
    #expect(summary.caskInfo == nil)
}

