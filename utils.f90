module utils
     
use numerics



 

INTEGER :: NX,NV,NT
REAL(RP) ::DX,DV,DT,TMAX,VMAX,L,EPS
REAL(RP),DIMENSION(:) , ALLOCATABLE:: X,V
REAL(RP),DIMENSION(:,:) , ALLOCATABLE:: FINIT, UEX, ERROR

CONTAINS


FUNCTION QUAD(H,F)

REAL(RP), INTENT(IN) :: H
REAL(RP), DIMENSION(:) ::F

INTEGER :: I
REAL(RP) ::QUAD

QUAD=ZERO

DO I=1,SIZE(F)-1

QUAD=QUAD+F(I)

END DO

QUAD=QUAD+(F(1)+F(SIZE(F)))*0.5_RP
QUAD=QUAD*H
RETURN

END FUNCTION QUAD





SUBROUTINE LANDAU_INIT(EPS,L)
REAL(RP), INTENT(IN) ::EPS, L
REAL(RP) ::K,XI
INTEGER :: I,J

K=0.5_rp

DO I=1,SIZE(FINIT,1)
	DO J=1,SIZE(FINIT,2)
	
    FINIT(I,J)=UN/SQRT(2._RP*PI)*(UN+EPS*COS(K*X(I)))*EXP(-0.5_RP*V(J)**2)
    END DO
END DO


END SUBROUTINE LANDAU_INIT


SUBROUTINE TEST_FINIT

INTEGER :: I,J



DO I=1,SIZE(FINIT,1)
	DO J=1,SIZE(FINIT,2)
	
    FINIT(I,J)=EXP(-10*X(I)**2)*EXP(-V(J)**2)
    END DO
END DO


END SUBROUTINE TEST_FINIT

FUNCTION U_EXACTE(T,Y,Z)

REAL(RP), INTENT(IN) ::Y,Z,T
REAL(RP) ::U_EXACTE
U_EXACTE=EXP(-10._RP*(Y*COS(T)-Z*SIN(T))**2)*EXP(-(Y*SIN(T)+Z*COS(T))**2)
RETURN
END FUNCTION U_EXACTE
SUBROUTINE INITILISATION(TIME,SPACE,SPEED)

REAL(RP), INTENT(IN):: TIME
INTEGER , INTENT(IN):: SPACE , SPEED
INTEGER :: I

TMAX=TIME

NX=SPACE
NV=SPEED
NT=INT(TMAX*500)

VMAX=10._RP
L=4.0_RP*PI
DX=L/NX
DV=2_RP*VMAX/NV
EPS=0.01_RP


ALLOCATE(FINIT(NX,NV))
ALLOCATE(X(NX))
ALLOCATE(V(NV))


DO I=1,NX
	X(I)=(I-1)*DX
END DO

DO I=1,NV
	V(I)=-VMAX+I*DV
END DO



CALL LANDAU_INIT(EPS,L)

CALL SAVE_INIT


END SUBROUTINE INITILISATION



SUBROUTINE TEST_INIT(TIME,SPACE,SPEED)

REAL(RP), INTENT(IN):: TIME
INTEGER , INTENT(IN)::SPACE, SPEED
INTEGER :: I

TMAX=TIME

NX=SPACE
NV=SPEED
NT=INT(TMAX*100)

VMAX=5._RP
DX=10._RP/NX
DV=2_RP*VMAX/NV
EPS=0.01_RP


ALLOCATE(FINIT(NX,NV))
ALLOCATE(X(NX))
ALLOCATE(V(NV))


DO I=1,NX
	X(I)=-5._RP+(I-1)*DX
END DO

DO I=1,NV
	V(I)=-VMAX+I*DV
END DO

CALL TEST_FINIT

CALL SAVE_INIT


END SUBROUTINE TEST_INIT




SUBROUTINE save_init

 
   
 
 integer :: I,J
 !stockage dans un fichier
    
      open(unit=16, file='LANDAU_INIT.txt', status='REPLACE')
        
       DO I=1,SIZE(FINIT,1)
			DO J=1,SIZE(FINIT,2)
	
					WRITE(16,*)  X(I),' ',V(J),' ',FINIT(I,J)
    
			END DO     
       END DO
    
       close(16)
   
END SUBROUTINE save_INIT


SUBROUTINE SPACE_ERR(A,T)

REAL(RP), INTENT(IN), DIMENSION(:,:) ::A
REAL(RP), INTENT(IN) ::T
INTEGER :: I, J

IF(.NOT. ALLOCATED(UEX))THEN
ALLOCATE(ERROR(NX,NV))
ALLOCATE(UEX(NX,NV))
END IF
ERROR=ZERO
DO I=1,NX-1
	DO J=1,NV-1
		UEX(I,J)=U_EXACTE(T,X(I),V(J))
	END DO
	
END DO
DO I=1,NX-1
	DO J=1,NV-1
		ERROR(I,J)=(A(I,J)-UEX(I,J))
	END DO
	
END DO

WRITE(*,*)'ERREUR L-2=',MAXVAL(ERROR)

END SUBROUTINE SPACE_ERR

end module utils
