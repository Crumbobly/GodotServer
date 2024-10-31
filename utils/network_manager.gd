extends Node

var references = {}

func register(_class_name: String, ref: Object) -> void:
	references[_class_name] = ref

func handle_request(request: Request):

	var _class_name = request.scene_class_name
	var function_name = request.func_name
	var args = request.args
	
	if references.has(_class_name):
		var obj = references[_class_name]
		if obj.has_method(function_name):
			obj.callv(function_name, args)
		else:
			assert(false, "Функция " + function_name + " не найдена в классе " + _class_name)
	else:
		assert(false, "Класс " + _class_name + " не зарегистрирован")
	
