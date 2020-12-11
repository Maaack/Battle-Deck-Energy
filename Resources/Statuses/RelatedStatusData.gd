extends StatusData


class_name RelatedStatusData

export(Resource) var relating_status : Resource

var target
var source

func duplicate(subresources:bool = false):
	# For some reason, duplicate() will not work on these by default.
	var dup = .duplicate(subresources)
	dup.target = target
	dup.source = source
	return dup
