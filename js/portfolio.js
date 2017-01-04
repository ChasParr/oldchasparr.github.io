function dropDown(id){
	document.getElementById(id).classList.toggle("show")
}

window.onclick = function(event){
	if (!event.target.matches('.projects')){
		var dropdowns = document.getElementsByClassName("dropdown");
		var i;
		for (i = 0; i < dropdowns.length; i++){
			if (dropdowns[i].classList.contains('show')){
				dropdowns[i].classList.remove('show');
			}
		}
	}
}