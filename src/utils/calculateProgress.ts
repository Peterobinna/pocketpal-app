export function calculateProgress(savedAmount: number, targetAmount: number): number {
  if (targetAmount <= 0) return 0;

  const progress = (savedAmount / targetAmount) * 100;
  return Math.min(Math.round(progress), 100);
}