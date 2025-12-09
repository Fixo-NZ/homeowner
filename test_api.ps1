$body = '{"rating":5,"comment":"Great service!","name":"John Doe"}'
$response = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/feedback/reviews" -Method POST -Headers @{"Content-Type"="application/json"; "Accept"="application/json"} -Body $body
$response | ConvertTo-Json -Depth 10
