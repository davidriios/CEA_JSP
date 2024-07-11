<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<%
	UserDet = SecMgr.getUserDetails(session.getId());
	if (UserDet != null) {
		//int maxInactiveInterval = 3000;//30 mins -> default value
		//System.out.println("..................... other1 = '"+UserDet.getOther1()+"'");
		try {
			maxInactiveInterval = Integer.parseInt(UserDet.getOther1());
			if (maxInactiveInterval <= 0) maxInactiveInterval = 30;
			maxInactiveInterval *= 60;

			//Set session inactive time validation variables
			session.setAttribute("_maxInactiveInterval",""+(maxInactiveInterval * 1000));
			session.setMaxInactiveInterval(maxInactiveInterval);
		} catch (Exception e) { System.out.println("User's Session Timeout is not defined, using value from properties file..."); }
	}
%>

