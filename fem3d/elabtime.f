
!--------------------------------------------------------------------------
!
!    Copyright (C) 1985-2018  Georg Umgiesser
!
!    This file is part of SHYFEM.
!
!    SHYFEM is free software: you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation, either version 3 of the License, or
!    (at your option) any later version.
!
!    SHYFEM is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with SHYFEM. Please see the file COPYING in the main directory.
!    If not, see <http://www.gnu.org/licenses/>.
!
!    Contributions to this file can be found below in the revision log.
!
!--------------------------------------------------------------------------

!================================================================
	module elabtime
!================================================================

	implicit none

	!private

	logical, save :: bdebugtime = .false.

	logical, save :: bdate_elab
	integer, save :: date_elab
	integer, save :: time_elab
	integer, save :: datetime_elab(2)
	double precision, save :: atime00

        logical, save :: btmin = .false.
        logical, save :: btmax = .false.
        logical, save :: binclusive_elab = .false.

        double precision, save :: atmin = 0.
        double precision, save :: atmax = 0.

        INTERFACE elabtime_in_time
	MODULE PROCEDURE elabtime_in_time_3,elabtime_in_time_1
        END INTERFACE

        INTERFACE elabtime_over_time
	MODULE PROCEDURE elabtime_over_time_3,elabtime_over_time_1
        END INTERFACE

!================================================================
	contains
!================================================================

!************************************************************

	subroutine elabtime_set_inclusive(binclusive)

! sets inclusive flag

	logical binclusive

	binclusive_elab = binclusive

	end subroutine elabtime_set_inclusive

!************************************************************

	subroutine elabtime_date_and_time(date,time)

! initializes elabtime module

	integer date,time

        bdate_elab = date .gt. 0
        if( bdate_elab ) call dtsini(date,time)

	date_elab = date
	time_elab = time
        datetime_elab = (/date,time/)
	call dts_to_abs_time(date,time,atime00)

	end subroutine elabtime_date_and_time

!************************************************************
!************************************************************
!************************************************************

	subroutine elabtime_set_minmax(stmin,stmax)

! converts stmin/stmax to absolute time

	character*(*) stmin,stmax

	integer ierr

        btmin = stmin .ne. ' '
        btmax = stmax .ne. ' '
        if( btmin ) then
	  call dts_string2time(stmin,atmin,ierr)
	  if( ierr /= 0 ) goto 99
	end if
        if( btmax ) then
	  call dts_string2time(stmax,atmax,ierr)
	  if( ierr /= 0 ) goto 99
	end if

        if( bdebugtime ) then
          write(6,*) 'time limits: '
          write(6,*) stmin(1:len_trim(stmin)),btmin,atmin
          write(6,*) stmax(1:len_trim(stmax)),btmax,atmax
        end if

	return
   99	continue
	write(6,*) 'stmin = ',trim(stmin)
	write(6,*) 'stmax = ',trim(stmax)
	stop 'error stop elabtime_set_minmax: cannot parse'
	end subroutine elabtime_set_minmax

!************************************************************
!************************************************************
!************************************************************

	function elabtime_in_time_3(atime,atimenew,atimeold)

! check if atime is inside time window - double version (absolute)

	logical elabtime_in_time_3
	double precision atime,atimenew,atimeold

	logical btimew

        btimew = .true.

        if( btmin ) btimew = btimew .and. atime >= atmin
        if( btmax ) btimew = btimew .and. atime <= atmax

	elabtime_in_time_3 = btimew

	if( bdebugtime ) then
	  write(6,*) 'exclusive..........',btimew,binclusive_elab
	  write(6,*) 'exclusive..........',atmin,atime,atmax
	end if

	if( btimew ) return			!already true
	if( .not. binclusive_elab ) return

        if( btmin ) then
	  btimew = btimew .or. (atime < atmin .and. atmin < atimenew)
	end if
        if( btmax ) then
	  btimew = btimew .or. (atimeold < atmax .and. atmax < atime)
	end if

	elabtime_in_time_3 = btimew

	end function elabtime_in_time_3

!************************************************************

	function elabtime_in_time_1(atime)

! check if atime is inside time window - double version (absolute)

	logical elabtime_in_time_1
	double precision atime

	elabtime_in_time_1 
     +			= elabtime_in_time_3(atime,atime,atime)

	end function elabtime_in_time_1

!************************************************************

	function elabtime_over_time_3(atime,atimenew,atimeold)

! check if atime is beyond time window - double version (absolute)

	logical elabtime_over_time_3
	double precision atime,atimenew,atimeold

	logical btimew

        btimew = .true.

        if( btmax ) btimew = btimew .and. atime <= atmax

	elabtime_over_time_3 = .not. btimew

	if( bdebugtime ) then
	  write(6,*) 'exclusive..........',btimew,binclusive_elab
	  write(6,*) 'exclusive..........',atmin,atime,atmax
	end if

	if( .not. binclusive_elab ) return

        if( btmax ) then
	  btimew = btimew .or. (atimeold < atmax .and. atmax < atime)
	end if

	elabtime_over_time_3 = .not. btimew

	end function elabtime_over_time_3

!************************************************************

	function elabtime_over_time_1(atime)

! check if atime is beyond time window - double version (absolute)

	logical elabtime_over_time_1
	double precision atime

	elabtime_over_time_1 
     +			= elabtime_over_time_3(atime,atime,atime)

	end function elabtime_over_time_1

!************************************************************

!================================================================
	end module elabtime
!================================================================

