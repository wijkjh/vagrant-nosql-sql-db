define profile::setprofile( $kvHome          = undef,
	                        $userBaseDir     = '/home',
	                        $user            = undef,
  )
{

  notice "Setting profile ${$userBaseDir}/${$user}"

  file { "${$userBaseDir}/${$user}/.bash_profile":
	ensure        => present,
	content       => template("profile/bash_profile.erb"),
	owner         => $user,
	group         => $user,
  }

}