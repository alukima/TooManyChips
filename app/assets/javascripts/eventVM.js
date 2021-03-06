function Item(data) {
    this.name = ko.observable(data.name);
    this.description = ko.observable(data.description);
    this.id = ko.observable(data.id);
    this.guestCreated = ko.observable(data.allow_guest_create);
    this.amountPromised = ko.observable(data.quantity_promised);
    this.quantity = ko.observable(data.quantity);
    this.amountToBring = ko.observable(0);
    this.eventId= ko.observable(data.event_id);
    this.stillNeeded = ko.observable(data.still_needed);
    this.range = ko.computed(function() {
        var list = []
        for (var i = 0; i <= this.stillNeeded(); i++) {
            list.push(i);
        }
        return list;
    }, this);
}

Item.prototype.toJSON = function() {
    var copy = ko.toJS(this); //easy way to get a clean copy
    delete copy.range; //remove an extra property
    return copy; //return the copy to be serialized
};


function Event(data) {
    var self = this;
    self.id = ko.observable(data.id );
    self.name = ko.observable(data.name);
    self.description = ko.observable(data.description);
    self.date = ko.observable(data.date);
    self.location = ko.observable(data.location);
    self.state = ko.observable(data.state);
    self.city = ko.observable(data.city);
    self.zip = ko.observable(data.zip);
    self.allow_guest_create = ko.observable(data.allow_guest_create);
    self.host_name = ko.observable(data.host_name);
    self.street_address = ko.observable(data.street_address);
    self.start_time = ko.observable(data.start_time);
    self.end_time = ko.observable(data.end_time);
    self.event_type = ko.observable(data.event_type);
    self.imageString = ko.observable(data.image);
    self.items = ko.observableArray([]);
    self.addItem = function() {
        self.items.unshift(new Item(""));
    }
    self.removeItem = function(item) { 
        self.items.remove(item);
        self.deletedItems.push(item.id());
        $.ajax("/event_items/"+item.id(), {
            data: ko.toJSON({ item: item }),
            type: "delete", contentType: "application/json"
        });
        
    };

    self.backgroundImage = ko.computed(function() {
        return { "backgroundImage": 'url(' + self.imageString() + ')' };
    }, self); 
    //editing data locally
    self.addItems = function(itemsArray){
        for (var i = 0; i < itemsArray.length; i++){
            self.items.push(new Item(itemsArray[i]));
        }
    }
};
//toJson Constructor
Event.prototype.toJSON = function() {
    var copy = ko.toJS(this); //easy way to get a clean copy
    delete copy.imageString; //remove an extra property
    delete copy.backgroundImage; //remove an extra property
    delete copy.items; //remove an extra property
    return copy; //return the copy to be serialized
};

function Guest(data) {
    var self = this;    
    self.email = ko.observable(data.email);
    self.name = ko.observable(data.name);
    self.items = ko.observableArray([]);
}
function MasterVM() {
    var self = this;    
    self.newItemName = ko.observable();
    self.items = ko.observableArray([]);
    self.events = ko.observableArray([]);
    self.currentEvent = ko.observable();
    self.editingText = ko.observable(false);
    self.editingItems = ko.observable(false);
    self.newEvent = ko.observable(new Event(''));
    self.guest = ko.observable(new Guest(''));
    //editing data locally
    self.addEvent = function(data) { 
        self.events.push(new Event(data));
    };
    self.removeEvent = function(event) { self.events.remove(event) }
    self.removeItem = function(item) { self.items.destroy(item);};
    //loading and saving data from the server
    self.save = function(data) {
        $.ajax("/events", {
            data: ko.toJSON({ event: data }),
            type: "post", contentType: "application/json"
        });
    }
    self.update = function(data) {
        $.ajax("/events/"+data.id(), {
            data: ko.toJSON({ event: data }),
            type: "patch", contentType: "application/json",
            success: function(result) {  }
        });
         $.ajax("/update_all_items/"+data.id(), {
            data: ko.toJSON({ event: data.items }),
            type: "post", contentType: "application/json",
            success: function(result) {  }
        });
    }
    self.submitPhoto = function(data){
        $('#upload_pic').click(function() {
            $("#form_id").ajaxForm().submit(); 
            console.log('within the submit block')
            $('#imageUpload').foundation('reveal', 'close');
            self.refreshPhoto();
            return false;
        });
    }
    self.refreshPhoto = function(){
        console.log('got here!!!!!!!!!!!!');
        $.ajax("/events/", {
            data: { id: $('.id').text() },
            type: "get", contentType: "application/json",
            success: function(result) { 
                console.log(result)
                $('.background').css("background-image","url("+result.image+")");
            }
        });
    }
    self.editDetails = function() {
        if (self.editingText() == false) {
            self.editingText(true);
        }
    }
    self.editItems = function() {
        if (self.editingItems() == false){
            self.editingItems(true);
        }
    }
    self.saveEvent = function() {
        if (self.editingItems() == true) {
            self.editingItems(false);
            self.update(self.currentEvent());
        }
        if (self.editingText() == true) {
            self.editingText(false);
            self.update(self.currentEvent());
        }
    }
    self.addGuest = function(data){
        console.log('yeah')
        array = self.currentEvent().items()
        data.items = array.filter(valueOfOneOrMore) 
        $.ajax("/create_guest/", {
            data: ko.toJSON({ user: data }),
            type: "post", contentType: "application/json",
            success: function(result) { console.log("") }
        });
    }
    self.getEvent = function(data) {
        $.ajax("/events/", {
            data: { id: $('.id').text() },
            type: "get", contentType: "application/json",
            success: function(result) { 
                self.currentEvent(new Event(result));
                self.currentEvent().addItems(result.items);
            }
        });
    }
    //supporting function
    function valueOfOneOrMore(item){return item.amountToBring() > 0}
    if ($('.getEvent').text() == 'true'){
        self.getEvent();
    }
}


// Scroll to Sticky Navbar
function sticky_relocate() {
    var window_top = $(window).scrollTop();
    if($('#sticky-anchor').offset()){
        var div_top = $('#sticky-anchor').offset().top ;
    }
    if (window_top > div_top) {
        $('#sticky').addClass('stick');
    } else {
        $('#sticky').removeClass('stick');
    }}

$(function () {
    $(window).scroll(sticky_relocate);
    sticky_relocate();
});
