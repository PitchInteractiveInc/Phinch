/* FileSaver.js By Eli Grey, http://eligrey.com
 * License: X11/MIT @source http://purl.eligrey.com/github/FileSaver.js/blob/master/FileSaver.js
 */

var saveAs = saveAs
  || (navigator.msSaveOrOpenBlob && navigator.msSaveOrOpenBlob.bind(navigator))
  || (function(view) {
  "use strict";
  var
      doc = view.document
    , get_URL = function() {
      return view.URL || view.webkitURL || view;
    }
    , URL = view.URL || view.webkitURL || view
    , save_link = doc.createElementNS("http://www.w3.org/1999/xhtml", "a")
    , can_use_save_link =  !view.externalHost && "download" in save_link
    , click = function(node) {
      var event = doc.createEvent("MouseEvents");
      event.initMouseEvent(
        "click", true, false, view, 0, 0, 0, 0, 0
        , false, false, false, false, 0, null
      );
      node.dispatchEvent(event);
    }
    , webkit_req_fs = view.webkitRequestFileSystem
    , req_fs = view.requestFileSystem || webkit_req_fs || view.mozRequestFileSystem
    , throw_outside = function (ex) {
      (view.setImmediate || view.setTimeout)(function() {
        throw ex;
      }, 0);
    }
    , force_saveable_type = "application/octet-stream"
    , fs_min_size = 0
    , deletion_queue = []
    , process_deletion_queue = function() {
      var i = deletion_queue.length;
      while (i--) {
        var file = deletion_queue[i];
        if (typeof file === "string") {
          URL.revokeObjectURL(file);
        } else { // file is a File
          file.remove();
        }
      }
      deletion_queue.length = 0; // clear queue
    }
    , dispatch = function(filesaver, event_types, event) {
      event_types = [].concat(event_types);
      var i = event_types.length;
      while (i--) {
        var listener = filesaver["on" + event_types[i]];
        if (typeof listener === "function") {
          try {
            listener.call(filesaver, event || filesaver);
          } catch (ex) {
            throw_outside(ex);
          }
        }
      }
    }
    , FileSaver = function(blob, name) {
      var
          filesaver = this
        , type = blob.type
        , blob_changed = false
        , object_url
        , target_view
        , get_object_url = function() {
          var object_url = get_URL().createObjectURL(blob);
          deletion_queue.push(object_url);
          return object_url;
        }
        , dispatch_all = function() {
          dispatch(filesaver, "writestart progress write writeend".split(" "));
        }
        , fs_error = function() {
          // don't create more object URLs than needed
          if (blob_changed || !object_url) {
            object_url = get_object_url(blob);
          }
          if (target_view) {
            target_view.location.href = object_url;
          } else {
                        window.open(object_url, "_blank");
                    }
          filesaver.readyState = filesaver.DONE;
          dispatch_all();
        }
        , abortable = function(func) {
          return function() {
            if (filesaver.readyState !== filesaver.DONE) {
              return func.apply(this, arguments);
            }
          };
        }
        , create_if_not_found = {create: true, exclusive: false}
        , slice
      ;
      filesaver.readyState = filesaver.INIT;
      if (!name) {
        name = "download";
      }
      if (can_use_save_link) {
        object_url = get_object_url(blob);
        save_link.href = object_url;
        save_link.download = name;
        click(save_link);
        filesaver.readyState = filesaver.DONE;
        dispatch_all();
        return;
      }
      if (view.chrome && type && type !== force_saveable_type) {
        slice = blob.slice || blob.webkitSlice;
        blob = slice.call(blob, 0, blob.size, force_saveable_type);
        blob_changed = true;
      }
      if (webkit_req_fs && name !== "download") {
        name += ".download";
      }
      if (type === force_saveable_type || webkit_req_fs) {
        target_view = view;
      }
      if (!req_fs) {
        fs_error();
        return;
      }
      fs_min_size += blob.size;
      req_fs(view.TEMPORARY, fs_min_size, abortable(function(fs) {
        fs.root.getDirectory("saved", create_if_not_found, abortable(function(dir) {
          var save = function() {
            dir.getFile(name, create_if_not_found, abortable(function(file) {
              file.createWriter(abortable(function(writer) {
                writer.onwriteend = function(event) {
                  target_view.location.href = file.toURL();
                  deletion_queue.push(file);
                  filesaver.readyState = filesaver.DONE;
                  dispatch(filesaver, "writeend", event);
                };
                writer.onerror = function() {
                  var error = writer.error;
                  if (error.code !== error.ABORT_ERR) {
                    fs_error();
                  }
                };
                "writestart progress write abort".split(" ").forEach(function(event) {
                  writer["on" + event] = filesaver["on" + event];
                });
                writer.write(blob);
                filesaver.abort = function() {
                  writer.abort();
                  filesaver.readyState = filesaver.DONE;
                };
                filesaver.readyState = filesaver.WRITING;
              }), fs_error);
            }), fs_error);
          };
          dir.getFile(name, {create: false}, abortable(function(file) {
            // delete file if it already exists
            file.remove();
            save();
          }), abortable(function(ex) {
            if (ex.code === ex.NOT_FOUND_ERR) {
              save();
            } else {
              fs_error();
            }
          }));
        }), fs_error);
      }), fs_error);
    }
    , FS_proto = FileSaver.prototype
    , saveAs = function(blob, name) {
      return new FileSaver(blob, name);
    }
  ;
  FS_proto.abort = function() {
    var filesaver = this;
    filesaver.readyState = filesaver.DONE;
    dispatch(filesaver, "abort");
  };
  FS_proto.readyState = FS_proto.INIT = 0;
  FS_proto.WRITING = 1;
  FS_proto.DONE = 2;

  FS_proto.error =
  FS_proto.onwritestart =
  FS_proto.onprogress =
  FS_proto.onwrite =
  FS_proto.onabort =
  FS_proto.onerror =
  FS_proto.onwriteend =
    null;

  view.addEventListener("unload", process_deletion_queue, false);
  return saveAs;
}(self));

if (typeof module !== 'undefined') module.exports = saveAs;
