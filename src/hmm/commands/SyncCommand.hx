package hmm.commands;

import sys.FileSystem;
import sys.io.File;

import hmm.HmmConfig;
import hmm.LibraryConfig;
import hmm.utils.Shell;
import hmm.utils.Log;

using thx.Options;

class SyncCommand implements ICommand {
  public var type(default, null) = "sync";

  public function new() {
  }

  public function run(args:Array<String>) {
    Shell.ensureHmmJsonExists();
    Shell.createLocalHaxelibRepoIfNotExists();
    var config = HmmConfigs.readHmmJsonOrThrow();
    for (library in config.dependencies)
    {
      switch (library)
      {
        case Haxelib(name, version):
          Log.println('Setting haxelib $name to version ${version.toArray().join('')}');
          Shell.haxelibInstall(name, version, {log: false, throwError: true});
          var args = ["set", name].concat(version.toArray());
          Shell.haxelib(args, {log: false, throwError: true});
        case Git(name, url, ref, dir):
          Log.println('Setting haxelib $name to git reference ${ref.toArray().join('')}');
          Shell.haxelibGit(name, url, null, dir, { log: false, throwError: true });
          Shell.gitCheckout(name, ref, false, {log: false, throwError: true});
        case Mercurial(_, _, _, _):
          Sys.println("Mercurial is not supported for sync command");
        case Dev(name, path):
          Log.println('Setting haxelib $name to development directory $path');
          Shell.haxelibDev(name, path, {log: false, throwError: true});
      }
    }
    Shell.haxelibList({ log: true, throwError: true });
  }

  public function getUsage() {
    return "updates and syncs libraries listed in hmm.json";
  }
}

