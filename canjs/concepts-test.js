var Example = can.Construct.extend({
  count: 1,
  increment: function() {
    this.count++;
  },
  init: function(count) {
    this.count = count;
  }
});

var example = new Example();
example.increment();

var Parent = can.Construct.extend({
  init: function(count) {
    this.count = count;
  },
  increase: function() {
    this.count++;
  },
  read: function(prefix) {
    return prefix + " " + String(this.count);
  }
});

var Child = Parent({
  // Child inherits the init function

  // Override increase

  increase: function() {
    this.count += 10;
  },
  // Add new function: decrease
  decrease: function() {
    this.count--;
  },
  // Override read, but call parents version
  read: function() {
    return this._super("Count is") + "!";
  }

})
