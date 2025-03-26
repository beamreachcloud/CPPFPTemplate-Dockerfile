// Copyright Epic Games, Inc. All Rights Reserved.

#include "CPPFPTemplateGameMode.h"
#include "CPPFPTemplateCharacter.h"
#include "UObject/ConstructorHelpers.h"

ACPPFPTemplateGameMode::ACPPFPTemplateGameMode()
	: Super()
{
	// set default pawn class to our Blueprinted character
	static ConstructorHelpers::FClassFinder<APawn> PlayerPawnClassFinder(TEXT("/Game/FirstPerson/Blueprints/BP_FirstPersonCharacter"));
	DefaultPawnClass = PlayerPawnClassFinder.Class;

}
