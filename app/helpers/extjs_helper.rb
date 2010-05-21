require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'javascript_tools')

module ExtjsHelper

  include Utils::JavascriptTools

  #  Renders Extjs.SimpleStore bound to a given array.
  #
  #  * <tt>collection</tt>:: +Hash+ with options. Keys are:
  #    * <tt>:type</tt>:: Collection type, can be either :objects for a collection of entities
  #                       or :arrays for a collection of arrays.
  #    * <tt>:data</tt>:: Collection itself.
  #    * <tt>:fields</tt>:: Fields of the entities to include.
  #
  #  == Example
  #  extjs_simple_store( { :data => @users,
  #                        :type => :objects,
  #                        :fields => ['login', 'id'] } )
  #
  def extjs_simple_store(collection)
    result_array = get_data_array_or_hash collection

    render :partial => "controls/simple_store.js.erb",
           :locals => {:collection => collection, :result_array => result_array}
  end

  #  Renders a javascript for creating Extjs.app.SearchField
  def extjs_search_field(options)
    options.symbolize_keys!

    render :partial => "controls/search_field.js.erb",
           :locals => {:options => options}
  end

  #  Renders Extjs.Store bound to a given array using Extjs.data.MemoryReader.
  #
  #  * <tt>collection</tt>:: +Hash+ with options. Keys are:
  #    * <tt>:type</tt>:: Collection type, can be either :objects for a collection of entities
  #                       or :arrays for a collection of arrays.
  #    * <tt>:data</tt>:: Collection itself.
  #    * <tt>:fields</tt>:: Fields of the entities to include.
  #
  #  == Example
  #  extjs_proxyfied_store( { :data => @users,
  #                        :type => :objects,
  #                        :fields => ['login', 'id'] } )
  #
  def extjs_paged_memory_store(collection)
    result_array = get_data_array_or_hash collection
    collection[:fields] << "__key" if collection[:key_index]

    render :partial => "controls/paged_memory_store.js.erb",
           :locals => {:collection => collection, :result_array => result_array}
  end

  #  Renders an Ext.Store, which uses ScriptTag proxy for fetching items from remote location.
  #  Configuration <tt>options</tt> are:
  #  * <tt>:url</tt>:: Url to fetch items from.
  #  * <tt>:custom_params</tt>:: Custom params to attach to the request, if any.
  #  * <tt>:reader</tt>:: Reader's preferences, that usually include
  #                       :totalProperty (defaults to 'total'), :root (defaults to 'data'), and :id (defaults to 'id') keys.
  #  * <tt>:per_page</tt>:: Items per page. Defaults to 20.
  #  * <tt>:fields</tt>:: As for usual ArrayReader, includes field specifications.
  #
  def extjs_paged_remote_store(options)
    options[:reader] = {:totalProperty => "total", :root => "data", :id => "id"}.merge(options[:reader] || {})
    options[:custom_params] ||= {}
    options[:per_page] ||= 20

    render :partial => "controls/paged_remote_store.js.erb",
           :locals => {:options => options}
  end

  def extjs_filtered_list(options)
    options[:panel] = strip_hash_keys_for_json(options[:panel] || {})
    options[:search] = strip_hash_keys_for_json(options[:search] || {})
    options[:view] = strip_hash_keys_for_json(options[:view] || {})

    render :partial => "controls/filtered_list.js.erb",
           :locals => {:options => options}
  end

  #  Renders an Ext.Toolbar.Button into the place. The button is wrapped with an inline div
  #  an behave almost identically to <tt>&lt;button /&gt;</tt> and <tt>&lt;input type="submit" /&gt;</tt>
  #  components in the layout. As for logic, any JS callback can be assigned to it using
  #  <tt>:handler</tt> option, but the default logic behind the component is to submit
  #  wrapping form.
  #
  def extjs_button(options)
    options = {:text => options} if options.is_a?(String)

    id = "_button_#{new_gui_id}"

    options[:handler] ||= strip_in_json("function() { Global.submitForm('#{id}'); }")

    if (!options[:handler].is_a?(StrippedJsonString))
      options[:handler] = options[:ajax].blank? ?  strip_in_json("function(){redirectTo('#{url_for(options[:handler])}');}")  :
                                                   strip_in_json("function(){new Ajax.Request('#{url_for(options[:handler])}', {onCreate: function(){if ($('#{options[:ajax_block]}')) {$('#{options[:ajax_block]}').startWaiting();}}, onComplete: function(){if ($('#{options[:ajax_block]}')) {$('#{options[:ajax_block]}').stopWaiting();}}, evalScripts: true, asynchronous: true});}")
    end

    render :partial => "controls/button.html.erb",
           :locals => {:options => options, :id => id}
  end

  #  Renders an Ext.Slider into the place.
  #
  def extjs_slider(model_name, model_field, options)
    options = {:renderTo => options} if options.is_a?(String)

    options[:minValue] ||= 0
    options[:value] ||= 0
    options[:maxValue] ||= 100

    span = options.delete(:span)

    populate_options_for_form_field model_name, model_field, options

    options = strip_hash_keys_for_json(options)
    render :partial => "controls/slider.js.erb",
           :locals => {:options => options, :id => id, :span => span}
  end

  #  Renders a custom Extjs.Store which is composed of JsonReader and ScriptProxy.
  #
  def extjs_json_store(options)
    options.symbolize_keys!

    options[:root] ||= "data"
    options[:total_count_property] ||= "total"
    options[:id_property] ||= "id"
    options[:remote_sorting] ||= true
    options[:fields] = strip_hash_keys_for_json(options[:fields] || [])
    options[:base_params] = strip_hash_keys_for_json(options[:baseParams] || {})
    render :partial => "controls/json_store.js.erb",
            :locals => {:options => options}
  end

  #  Renders grid column model constructor
  #
  def extjs_grid_column_model(column_specs)
    column_specs.each do |col|
      col[:menuDisabled] ||= true
      col[:resizable] ||= false
    end
    columns = strip_hash_keys_for_json(column_specs)

    render :partial => "controls/grid_column_model.js.erb",
            :locals => {:columns => columns}
  end

  def extjs_grid_bound_column_renderer(options)
    render :partial => "controls/grid_bound_column_rederer.js.erb",
            :locals => {:options => options}
  end
  
  def extjs_grid(options)
    options.symbolize_keys!
    options[:sm] ||= "new Ext.grid.RowSelectionModel({singleSelect: true})".j
    options = strip_hash_keys_for_json(options)

    render :partial => "controls/grid.js.erb",
            :locals => {:options => options}
  end
  
  def extjs_toolbar_button(text, button_options = {}, options = {})
    if options[:handler]
      handler = options[:handler]
    elsif not options.blank?
      handler = "function() {
        Ext.Ajax.request(#{strip_hash_keys_for_json(options).to_json});
        }".j
    end
    { :text => text, :handler => handler }.merge(button_options)
  end

  #  Renders Extjs.ComboBox
  #
  def extjs_combo_box(model_name, model_field, options = {})
    options.symbolize_keys!
    options.merge({:id_field => "id"})

    options[:typeAhead] ||= true
    options[:mode] ||= "local"
    options[:valueField] ||= "id"
    options[:emptyText] ||= "Выберите..."
    options[:editable] = options[:editable].nil? ? false : options[:editable]
    #options[:forceSelection] = options[:forceSelection].nil? ? true : options[:forceSelection]
    options[:triggerAction] ||= "all"

    options[:store] = strip_in_json(options[:store]) if options[:store]

    populate_options_for_form_field model_name, model_field, options

    render :partial => "controls/combo_box.js.erb",
           :locals => {:options => strip_hash_keys_for_json(options)}
  end
  
  #  Renders Extjs.GroupComboBox
  #
  def extjs_group_combo_box(model_name, model_field, options = {})
    options.symbolize_keys!
    options.merge({:id_field => "id"})

    options[:typeAhead] ||= true
    options[:mode] ||= "local"
    options[:valueField] ||= "id"
    options[:emptyText] ||= "Choose..."
    options[:editable] ||= false
    options[:triggerAction] ||= "all"
    options[:forceSelection] ||= true
    options[:startCollapsed] ||= true
    options[:showGroupName] ||= false
    options[:store] = strip_in_json(options[:store]) if options[:store]

    populate_options_for_form_field model_name, model_field, options

    render :partial => "controls/group_combo_box.js.erb",
           :locals => {:options => strip_hash_keys_for_json(options)}
  end

  #  Renders Extjs.HtmlEditor
  #
  def extjs_html_editor(model_name, model_field, options = {})
    options.symbolize_keys!
    populate_options_for_form_field model_name, model_field, options

    options[:name] = options[:hiddenName]
    options[:value] ||= ""

    render :partial => "controls/html_editor.js.erb",
           :locals => {:options => strip_hash_keys_for_json(options).to_json}
  end

  #  Renders Extjs.DateField
  #
  def extjs_date_field(model_name, model_field, options = {})
    options.symbolize_keys!
    populate_options_for_form_field model_name, model_field, options
    options[:name] ||= options[:hiddenName] unless options[:merged]
    options[:format] ||= "d-m-Y"
    render :partial => "controls/date_field.js.erb",
            :locals => {:options => strip_hash_keys_for_json(options)}
  end

  #  Renders Extjs.TimeField
  #
  def extjs_time_field(model_name, model_field, options = {})
    options.symbolize_keys!
    populate_options_for_form_field model_name, model_field, options
    options[:name] ||= options[:hiddenName] unless options[:merged]

    render :partial => "controls/time_field.js.erb",
            :locals => {:options => strip_hash_keys_for_json(options)}
  end

  #  Renders Extjs.form.TextArea
  #
  def extjs_text_area_field(model_name, model_field, options = {})
    options.symbolize_keys!
    populate_options_for_form_field model_name, model_field, options

    options[:name] = options.delete(:hiddenName)

    render :partial => "controls/text_area_field.js.erb",
            :locals => {:options => strip_hash_keys_for_json(options).to_json}
  end

  #  Renders Extjs.TextField
  #
  def extjs_text_field(model_name, model_field, options = {})
    options.symbolize_keys!

    populate_options_for_form_field model_name, model_field, options
    options[:name] ||= options.delete(:hiddenName)

    render :partial => "controls/text_field.js.erb",
           :locals => {:options => strip_hash_keys_for_json(options).to_json}
  end

  #  Renders Extjs.Field with inputType = "file"
  #
  def extjs_upload(model_name, model_field, options = {})
    options.symbolize_keys!

    populate_options_for_form_field model_name, model_field, options
    options[:name] ||= options.delete(:hiddenName)
    options[:inputType] = "file"

    render :partial => "controls/upload.js.erb",
           :locals => {:options => strip_hash_keys_for_json(options).to_json}
  end

  def dropdown(el, label, items, options ={})
    empty_template =  {
            :label => options[:empty_template][:label] || "&nbsp;",
            :url => options[:empty_template][:url] || "#"}
    items = items.collect do |c|
      {
            :label => "#{c[:label]}",
            :url => c[:url] }
    end
    items << {:label => empty_template[:label], :url => empty_template[:url] } if items.empty?
    render :partial =>"controls/dropdown.js.erb", :locals => {:el => el, :label => label, :items => items.to_json, :link => options[:link]}
  end

  #  Renders Extjs.Checkbox
  #
  def extjs_checkbox(model_name, model_field, options = {})
    options.symbolize_keys!

    options[:inputValue] = options.delete(:checkedValue)

    populate_options_for_form_field model_name, model_field, options

    options[:name] ||= options.delete(:hiddenName)
    options[:checked] = options[:value] == options[:inputValue]

    render :partial => "controls/checkbox.js.erb",
           :locals => {:options => strip_hash_keys_for_json(options)}
  end

  #  Renders Extjs.Radio
  #
  def extjs_radio(model_name, model_field, options = {})
    options.symbolize_keys!

    options[:inputValue] = options.delete(:checkedValue)

    populate_options_for_form_field model_name, model_field, options

    options[:name] ||= options.delete(:hiddenName)

    render :partial => "controls/radio.js.erb",
           :locals => {:options => strip_hash_keys_for_json(options)}
  end

  #  Renders a complete combo box control. Is needs storage as the original +extjs_combo_box+ helper,
  #  but doesn't require underlying field anymore.
  #
  def extjs_combo_box_control(model_name, model_field, options = {})
    id = "_combo_box_#{new_gui_id}"
    options.delete :applyTo
    unless options.delete(:render) == false
      options[:renderTo] = id
    end
    validation = add_validation_errors(model_name, options[:borrow_errors_from] || model_field, options[:js_variable] || id, options)

    if options[:values]
      lines = ["var " + id + "_store = " + extjs_simple_store({:type => :arrays, :fields => ["id", "title"], :data => options[:values]})]
      options[:store] = id + "_store"
      options[:displayField] = "title"
      options[:valueField] = "id"
    end

    options[:valueNotFoundText] ||= "Выберите..."

    lines ||= []
    lines << (options.delete(:js_variable) || "var " + id) + " = " + extjs_combo_box(model_name, model_field, options) << validation

    control_wrapper(id, lines)
  end
  
  #  Renders a complete group combo box control.
  #
  def extjs_group_combo_box_control(model_name, model_field, options = {})
    id = "_group_combo_box_#{new_gui_id}"
    options.delete :applyTo
    options[:renderTo] = id

    validation = add_validation_errors(model_name, options[:borrow_errors_from] || model_field, options[:js_variable] || id, options)

    if options[:values]
      lines = ["var " + id + "_store = " + extjs_simple_store({:type => :arrays, :fields => ["id", "title"], :data => options[:values]})]
      options[:store] = id + "_store"
      options[:displayField] = "title"
      options[:valueField] = "id"
    end

    options[:valueNotFoundText] ||= "Выберите..."

    lines ||= []
    lines << (options.delete(:js_variable) || "var " + id) + " = " + extjs_group_combo_box(model_name, model_field, options) << validation

    control_wrapper(id, lines)
  end

  #  Renders a complete text area control.
  #
  def extjs_text_area_control(model_name, model_field, options = {})
    id = "_text_area_#{new_gui_id}"
    options.delete :applyTo
    options[:renderTo] = id

    validation = add_validation_errors(model_name, options[:borrow_errors_from] || model_field, options[:js_variable] || id, options)
    control_wrapper(id, [(options.delete(:js_variable) || "var " + id) + " = " + extjs_text_area_field(model_name, model_field, options),
                         validation])
  end

  #  Renders a complete text box control.
  #
  def extjs_text_field_control(model_name, model_field, options = {})
    id = "_text_field_#{new_gui_id}"
    options.delete :applyTo
    options[:renderTo] = id

    validation = add_validation_errors(model_name, options[:borrow_errors_from] || model_field, options[:js_variable] || id, options)
    js_var = options.delete(:js_variable)
    no_clearer = options[:no_clearer].nil? ? false : options[:no_clearer]
    control_wrapper(id, [("var #{id} = " + (js_var.blank? ? "" : (js_var + " = "))) + extjs_text_field(model_name, model_field, options),
                         validation, add_form_handlers(id)], no_clearer)
  end

  #  Renders a complete checkbox control.
  #
  def extjs_checkbox_control(model_name, model_field, options = {})
    id = "_checkbox_#{new_gui_id}"
    options.delete :applyTo
    options[:renderTo] = id

    validation = add_validation_errors(model_name, options[:borrow_errors_from] || model_field, options[:js_variable] || id, options)
    control_wrapper(id, [(options.delete(:js_variable) || "var " + id) + " = " + extjs_checkbox(model_name, model_field, options),
                         validation])
  end

  #  Renders a complete radio control.
  #
  def extjs_radio_control(model_name, model_field, options = {})
    id = "_radio_#{new_gui_id}"
    options.delete :applyTo
    options[:renderTo] = id

    validation = add_validation_errors(model_name, options[:borrow_errors_from] || model_field, options[:js_variable] || id, options)
    control_wrapper(id, [(options.delete(:js_variable) || "var " + id) + " = " + extjs_radio(model_name, model_field, options),
                         validation])
  end

  #  Renders a complete slider control.
  #
  def extjs_slider_control(model_name, model_field, options = {})
    id = "_slider_#{new_gui_id}"
    options.delete :applyTo
    options[:renderTo] = id

    validation = add_validation_errors(model_name, options[:borrow_errors_from] || model_field, options[:js_variable] || id, options)
    control_wrapper(id, [(options.delete(:js_variable) || "var " + id) + " = " + extjs_slider(model_name, model_field, options),
                         validation])
  end

  #  Renders a complete date control.
  #
  def extjs_date_field_control(model_name, model_field, options = {})
    id = options.delete(:js_variable) || "_date_field_#{new_gui_id}"
    options.delete :applyTo
    options[:renderTo] = id

    validation = add_validation_errors(model_name, options[:borrow_errors_from] || model_field, options[:js_variable] || id, options)
    control_wrapper(id, [(options.delete(:js_variable) || "var " + id) + " = " + extjs_date_field(model_name, model_field, options),
                         validation])
  end

  #  Renders a complete time control.
  #
  def extjs_time_field_control(model_name, model_field, options = {})
    id = options.delete(:js_variable) || "_time_field_#{new_gui_id}"
    options.delete :applyTo
    options[:renderTo] = id

    validation = add_validation_errors(model_name, options[:borrow_errors_from] || model_field, options[:js_variable] || id, options)
    control_wrapper(id, [(options.delete(:js_variable) || "var " + id) + " = " + extjs_time_field(model_name, model_field, options),
                         validation])
  end

  #  Renders a complete html editor control.
  #
  def extjs_html_editor_control(model_name, model_field, options = {})
    js_var = options.delete(:js_variable)
    id = "_html_area_#{new_gui_id}"
    options.delete :applyTo
    options.delete(:lazyRender).blank? ? (options[:renderTo] = id) : (options[:lazyRenderId] = id)
    validation = add_validation_errors(model_name, options[:borrow_errors_from] || model_field, options[:js_variable] || id, options)
    control_wrapper(id, ["var #{id} =" + (js_var.blank? ? "" : (js_var + " = ")) + extjs_html_editor(model_name, model_field, options),
                         validation])
  end

  #  Renders a complete search field control.
  #
  def extjs_search_field_control(options = {})
    id = options.delete(:js_variable) || "_html_area_#{new_gui_id}"
    options.delete :applyTo
    options[:renderTo] = id

    control_wrapper(id, ["var " + (options.delete(:js_variable) || id) + " = " + extjs_search_field(options)])
  end

  #  Renders a complete upload control.
  #
  def extjs_upload_control(model_name, model_field, options = {})
    id = "_upload_#{new_gui_id}"
    options.delete :applyTo
    options[:renderTo] = id
    js_var = options.delete(:js_variable)
    validation = add_validation_errors(model_name, options[:borrow_errors_from] || model_field, options[:js_variable] || id, options)
    control_wrapper(id, [("var #{id} = " + (js_var.blank? ? "" : (js_var + " = "))) + extjs_upload(model_name, model_field, options),
                         validation])
  end
  
  #  Renders an array of hashes to use as items collection for a form panel.
  #
  def extjs_form_fields(model_name, field_configs)
    obj = instance_variable_get("@#{model_name}")
    field_configs.collect do |fc|
      field_name = fc.delete(:name)
      raw_value = nil
      name = "#{model_name}[#{field_name}]"
      if obj and obj.respond_to?(field_name)      
        raw_value = obj.send(field_name)
      end
      
      fc[:name] = name 
      fc[:value] = format_field_value(raw_value) if obj and raw_value
      fc[:checked] = raw_value if [true, false].include?(raw_value)
      fc
    end.to_json
  end
  
  #  Returns +value+ formatted properly for use with ExtJS controls.
  #
  def format_field_value(value)
    case value
    when Time:
      return value.to_s(:date)
    else
      return value
    end
  end

  #  Returns a string containing the intialization of error message on the field
  #
  def add_validation_errors(model_name, model_field, js_variable, options)
    model = instance_variable_get("@#{model_name}")
    return unless model
    errors = model.errors.on(model_field).to_a
    return if errors.blank?

    text = ''

    errors.to_a.each do |error|
      text += "<div class=\"validation-error\">#{model.class.human_attribute_name model_field.to_s} #{error}</div>"
    end

    options[:msgTarget] ||= "side"
    "#{js_variable}.markInvalid(#{text.inspect})"
  end

  #  Returns a piece of text composed of the div element, script tag with Ext.onReady handler
  #  filled with <tt>control_js_code</tt>. The div is aasigned the given <tt>id</tt> and a class
  #  sms-extjs-control.
  #
  #  * <tt>id</tt>:: The id to assign to div.
  #  * <tt>lines</tt>:: The js code to place into handler. Can be an array of +String+ or a single +String+.
  #
  def control_wrapper(id, lines, no_clearer = false)
    lines = lines.to_a
    "<div class=\"sms-extjs-control-wrapper form-item x-form-element\">
       <div class=\"sms-extjs-control\" id=\"#{id}\"></div>
     </div>
     #{no_clearer ? '' : '<div class=\"clear\"></div>'}
     <script type=\"text/javascript\">
       Ext.onReady(function() {
         #{lines.join ";\n"};
       });
     </script>"
  end

  #  Attempts to populate the :value element of the given +Hash+ <tt>options</tt> with the value
  #  of specified model field.
  #
  #  * <tt>model_name</tt>:: The name of the model variable to use.
  #  * <tt>model_field</tt>:: The name of the field of the model.
  #  * <tt>options</tt>:: A +Hash+ with options.
  #
  def populate_options_for_form_field(model_name, model_field, options)
    options[:hiddenName] = "#{model_name}[#{model_field}]" if model_name and model_field

    model = instance_variable_get("@#{model_name}")
    unless (model.blank? || !model.respond_to?(model_field))
      value = model.send(model_field)
      case value
        when Date: options[:value] ||= date_only_json(value)
        when Time: options[:value] ||= value.to_s(:date)
        when ActiveRecord::Base: options[:value] ||= value.id
      else
        options[:value] ||= value
      end
    end
  end

  #  Converts the given collection of objects into the array of arrays, where each inner array is the
  #  representation of the data record.
  #
  def objects_to_collection_array(collection)
    collection[:data].collect do |element|
      record = collection[:fields].collect do |field|
        element.send field
      end

      record << record[collection[:key_index]] if collection[:key_index]
      record
    end
  end

  #  Converts the given collection of +Hash+ objects into the array of arrays, where each inner array is the
  #  representation of the data record.
  #
  def hashes_to_collection_array(collection)
    collection[:data].collect do |element|
      entry = element.symbolize_keys
      record = collection[:fields].collect do |field|
         entry[field.to_sym]
      end

      record << record[collection[:key_index]] if collection[:key_index]
      record
    end
  end

  #  Retruns a stripped JSON string that contains only date
  #  of the given +DateTime+ object.
  #
  #  * <tt></tt>:: +DateTime+ object to serailize into json.
  #
  def date_only_json(datetime)
    strip_in_json(datetime.to_json(:omit_time => true))
  end

  #  Being given a settings object, returns an array of arrays with data fields.
  #
  #  * <tt>collection</tt>:: A +Hash+ with :type and :data elements, where type if either :objects,
  #                          or :hashes, or :arrays and the :data is the corresponding collection.
  #
  def get_data_array_or_hash(collection)
    case collection[:type]
      when :objects:
        return objects_to_collection_array(collection)
      when :hashes:
        return hashes_to_collection_array(collection)
      when :arrays:
        return collection[:data]
    end
  end

  def add_form_handlers(var)
    "#{var}.on('specialkey', function(field, event) {
      if (event.getKey() == Ext.EventObject.TAB) {
        return true;
      }

      if (event.getKey() == Ext.EventObject.ENTER) {
        Global.submitForm(field.getEl().id);
      }
    });"
  end

end
