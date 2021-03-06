message_app = angular.module("Message", ["ngResource"])

message_app.config(["$httpProvider", (provider) ->
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
])

message_app.factory "Message", ["$resource", ($resource) ->
	$resource("/projects/:project_id/messages/:id/:action", 
		{ 
			project_id: location.pathname.split('/')[2], 
			id: "@id"
		}, 
		{ 
			update: {method: "PUT"},
			create_comment: {method: 'POST'}
		}
		)
]

@MessageCtrl = ["$scope", "Message", ($scope, Message) ->

	$scope.messages = Message.query()

	$scope.addMessage = () ->
		message = Message.save($scope.newMessage, ->
			$scope.messages.push(message)
			$scope.newMessage = {}
			)

	$scope.comment_pool = []

	$scope.addComment = () ->

		$scope.newComment.author_id = $("#author_id").val()
		$scope.newComment.author_name = $("#author_name").val()
		$scope.message_id = $("#message_id").val()

		Message.create_comment(
			{
				action: "create_comment", 
				id: $scope.message_id
			},
			{
				comment: $scope.newComment
			}, 
			)

	socket = io.connect("http://localhost:5001")
	message_id = $('#message_id').val()

	if( message_id != undefined )
		socket.on "message-comment-#{message_id}", (data) ->

			$('#comment-pool').append("<li class='lead well'><a href='#'>#{data.author_name}</a> said: #{data.content} </li>")
			$scope.newComment = {}
]
