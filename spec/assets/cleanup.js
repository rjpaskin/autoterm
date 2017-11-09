function run(ARGV) {
  Application("iTerm").windows().forEach(function(win) {
    try {
      if (ARGV.indexOf(win.id().toString()) !== -1) {
        win.close()
      }
    } catch(err) {
      // console.log()
    }
  });
}
